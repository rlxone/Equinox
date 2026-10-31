// Copyright (c) 2026 CodingMarkus
//
// Portions adapted from oxideav-heif.
// Copyright (c) 2026 Karpelès Lab Inc.
//
// MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

enum HEIFMuxer {
	private struct Property {
		let box: Data
		let essential: Bool
	}

	private struct ImageItem {
		let type: String
		let bytes: Data
		let properties: [Property]
	}

	private struct Box {
		let type: Data
		let start: Int
		let payloadStart: Int
		let end: Int
	}

	private enum MuxError: Error {
		case invalidFile
		case unsupportedFile
		case overflow
	}

	static func pack(_ sources: [Data], xmp: Data) -> Data? {
		guard sources.count > 1,
			  sources.count < Int(UInt16.max) else { return nil }

		do {
			let frames = try sources.map { try readFrame($0, at: 0) }
			return try write(frames, xmp: xmp)
		} catch {
			return nil
		}
	}

	static func packFrames(
		_ sources: [(data: Data, index: Int)],
		xmp: Data
	) -> Data? {
		guard !sources.isEmpty,
				sources.count < Int(UInt16.max) else { return nil }

		do {
			let frames = try sources.map { source in
				try readFrame(source.data, at: source.index)
			}
			return try write(frames, xmp: xmp)
		} catch {
			return nil
		}
	}

	static func primaryCodedPayload(in data: Data) -> Data? {
		try? readPrimaryImage(data).bytes
	}

	static func extractImage(in data: Data, at index: Int) -> Data? {
		guard index >= 0 else { return nil }
		do {
			if let grid = try readGridFrame(data, at: index) {
				return try write([grid], xmp: nil)
			}
			let image = try readImage(data, at: index)
			return try write([[image]], xmp: nil)
		} catch {
			return nil
		}
	}

	private static func readPrimaryImage(_ data: Data) throws -> ImageItem {
		try readImage(data, at: nil)
	}

	private static func readFrame(
		_ data: Data,
		at index: Int
	) throws -> [ImageItem] {
		if let grid = try readGridFrame(data, at: index) {
			return grid
		}
		let imageIndex: Int? = index == 0 ? nil : index
		return [try readImage(data, at: imageIndex)]
	}

	private static func readImage(
		_ data: Data,
		at index: Int?
	) throws -> ImageItem {
		let topLevel = try boxes(in: data, range: 0..<data.count)
		guard let ftyp = topLevel.first,
				fourCC(ftyp.type) == "ftyp",
				let meta = topLevel.first(where: { fourCC($0.type) == "meta" })
		else { throw MuxError.invalidFile }
		guard ftyp.end - ftyp.payloadStart >= 8,
				meta.end - meta.payloadStart >= 4 else {
			throw MuxError.invalidFile
		}

		let brands = data[(ftyp.payloadStart + 4)..<ftyp.end]
		guard brands.count.isMultiple(of: 4) else {
			throw MuxError.invalidFile
		}

		let children = try boxes(
			in: data,
			range: (meta.payloadStart + 4)..<meta.end
		)
		guard let primaryBox = children.first(where: {
			fourCC($0.type) == "pitm"
		}), let infoBox = children.first(where: {
			fourCC($0.type) == "iinf"
		}), let locationBox = children.first(where: {
			fourCC($0.type) == "iloc"
		}), let propertiesBox = children.first(where: {
			fourCC($0.type) == "iprp"
		}) else { throw MuxError.invalidFile }

		let primaryID = try primaryItemID(data, box: primaryBox)
		let itemID: UInt32
		if let index = index {
			let ids = try imageItemIDs(data, box: infoBox)
			guard ids.indices.contains(index) else {
				throw MuxError.invalidFile
			}
			itemID = ids[index]
		} else {
			itemID = primaryID
		}
		let itemType = try itemType(data, box: infoBox, itemID: itemID)
		guard itemType == "hvc1" else { throw MuxError.unsupportedFile }

		if let referencesBox = children.first(where: {
			fourCC($0.type) == "iref"
		}), try hasUnsupportedReferences(
			data,
			box: referencesBox,
			primaryID: itemID
		) {
			throw MuxError.unsupportedFile
		}

		let payload = try itemPayload(
			data,
			box: locationBox,
			itemID: itemID
		)
		let properties = try itemProperties(
			data,
			box: propertiesBox,
			itemID: itemID
		)
		guard properties.contains(where: {
			fourCC(boxType($0.box)) == "hvcC"
		}), properties.contains(where: {
			fourCC(boxType($0.box)) == "ispe"
		}) else { throw MuxError.unsupportedFile }

		return ImageItem(type: "hvc1", bytes: payload,
						 properties: properties)
	}

	private static func readGridFrame(
		_ data: Data,
		at index: Int
	) throws -> [ImageItem]? {
		let topLevel = try boxes(in: data, range: 0..<data.count)
		guard let ftyp = topLevel.first,
				fourCC(ftyp.type) == "ftyp",
				let meta = topLevel.first(where: {
					fourCC($0.type) == "meta"
				}), meta.end - meta.payloadStart >= 4 else {
			throw MuxError.invalidFile
		}
		let children = try boxes(in: data,
								 range: (meta.payloadStart + 4)..<meta.end)
		guard let info = children.first(where: {
			fourCC($0.type) == "iinf"
		}), let locations = children.first(where: {
			fourCC($0.type) == "iloc"
		}), let properties = children.first(where: {
			fourCC($0.type) == "iprp"
		}) else { throw MuxError.invalidFile }
		let imageIDs = try imageItemIDs(data, box: info)
		guard imageIDs.indices.contains(index) else {
			throw MuxError.invalidFile
		}
		let imageID = imageIDs[index]
		guard try itemType(data, box: info, itemID: imageID) == "grid" else {
			return nil
		}
		guard let references = children.first(where: {
			fourCC($0.type) == "iref"
		}) else { throw MuxError.invalidFile }
		let tiles = try derivedItemIDs(data, box: references, from: imageID)
		guard !tiles.isEmpty,
				tiles.count < Int(UInt16.max),
				Set(tiles).count == tiles.count else {
			throw MuxError.unsupportedFile
		}
		let ids = [imageID] + tiles
		let idatStart = children.first(where: {
			fourCC($0.type) == "idat"
		})?.payloadStart
		return try ids.enumerated().map { order, id in
			let type = try itemType(data, box: info, itemID: id)
			guard type == (order == 0 ? "grid" : "hvc1") else {
				throw MuxError.unsupportedFile
			}
			let bytes = try itemPayload(data, box: locations,
										itemID: id, idatStart: idatStart)
			let itemProperties = try itemProperties(
				data,
				box: properties,
				itemID: id
			)
			let required = order == 0 ? ["ispe"] : ["hvcC", "ispe"]
			guard required.allSatisfy({ requiredType in
				itemProperties.contains(where: {
					fourCC(boxType($0.box)) == requiredType
				})
			}) else { throw MuxError.unsupportedFile }
			return ImageItem(type: type, bytes: bytes,
							 properties: itemProperties)
		}
	}

	private static func derivedItemIDs(
		_ data: Data,
		box: Box,
		from itemID: UInt32
	) throws -> [UInt32] {
		guard box.end - box.payloadStart >= 4 else {
			throw MuxError.invalidFile
		}
		let version = data[box.payloadStart]
		guard version <= 1 else { throw MuxError.unsupportedFile }
		let references = try boxes(in: data,
								   range: (box.payloadStart + 4)..<box.end)
		var targets: [UInt32] = []
		for reference in references where fourCC(reference.type) == "dimg" {
			let cursor = Cursor(data: data,
									offset: reference.payloadStart,
									end: reference.end)
			let from = version == 0
				? UInt32(try cursor.read16()) : try cursor.read32()
			let count = try cursor.read16()
			for _ in 0..<count {
				let target = version == 0
					? UInt32(try cursor.read16()) : try cursor.read32()
				if from == itemID { targets.append(target) }
			}
		}
		return targets
	}

	private static func write(
		_ frames: [[ImageItem]],
		xmp: Data?
	) throws -> Data {
		let images = frames.flatMap { $0 }
		guard images.count < Int(UInt16.max),
				!frames.isEmpty,
				frames.allSatisfy({ !$0.isEmpty }),
				(xmp?.count ?? 0) <= Int(UInt32.max) - 8,
				images.allSatisfy({ $0.properties.count <= Int(UInt8.max) })
		else { throw MuxError.overflow }

		var items = frames.flatMap { frame in
			frame.enumerated().map { index, image in
				(type: image.type, name: "",
				 contentType: nil as String?, data: image.bytes,
				 properties: image.properties, hidden: index > 0)
			}
		}
		let primaryID: UInt32 = 1
		let metadataID = UInt16(images.count + 1)
		if let xmp = xmp {
			items.append((type: "mime", name: "",
						  contentType: "application/rdf+xml",
						  data: xmp, properties: [], hidden: false))
		}

		var propertyBoxes: [Data] = []
		var propertyIndices: [Data: UInt16] = [:]
		var associations: [[(UInt16, Bool)]] = []
		for item in items {
			var itemAssociations: [(UInt16, Bool)] = []
			for property in item.properties {
				let propertyIndex: UInt16
				if let existingIndex = propertyIndices[property.box] {
					propertyIndex = existingIndex
				} else {
					guard propertyBoxes.count < 0x7fff else {
						throw MuxError.overflow
					}
					propertyBoxes.append(property.box)
					propertyIndex = UInt16(propertyBoxes.count)
					propertyIndices[property.box] = propertyIndex
				}
				itemAssociations.append((propertyIndex, property.essential))
			}
			associations.append(itemAssociations)
		}

		let largePropertyIndices = propertyBoxes.count > 127
		var ipco = Data()
		for property in propertyBoxes { ipco.append(property) }
		var ipmaBody = be32(UInt32(items.count))
		for (index, _) in items.enumerated() {
			ipmaBody.append(be16(UInt16(index + 1)))
			ipmaBody.append(UInt8(associations[index].count))
			for (propertyIndex, essential) in associations[index] {
				if largePropertyIndices {
					let value = propertyIndex | (essential ? 0x8000 : 0)
					ipmaBody.append(be16(value))
				} else {
					ipmaBody.append(UInt8(propertyIndex)
									| (essential ? 0x80 : 0))
				}
			}
		}
		let iprp = box("iprp", box("ipco", ipco)
					   + fullBox("ipma", version: 0,
								 flags: largePropertyIndices ? 1 : 0,
								 body: ipmaBody))

		var handlerBody = Data(repeating: 0, count: 4)
		handlerBody.append(Data("pict".utf8))
		handlerBody.append(Data(repeating: 0, count: 13))
		let handler = fullBox("hdlr", version: 0, flags: 0,
							  body: handlerBody)
		let primary = fullBox("pitm", version: 0, flags: 0,
							  body: be16(UInt16(primaryID)))

		var itemInfoBody = be16(UInt16(items.count))
		for (index, item) in items.enumerated() {
			var body = be16(UInt16(index + 1))
			body.append(be16(0))
			body.append(Data(item.type.utf8))
			body.append(Data(item.name.utf8))
			body.append(0)
			if let contentType = item.contentType {
				body.append(Data(contentType.utf8))
				body.append(0)
			}
			itemInfoBody.append(fullBox("infe", version: 2,
										 flags: item.hidden ? 1 : 0,
										 body: body))
		}
		let itemInfo = fullBox("iinf", version: 0, flags: 0,
							   body: itemInfoBody)

		var references = Data()
		var frameStart = 0
		for frame in frames {
			let tileCount = frame.count - 1
			if tileCount > 0 {
				var body = be16(UInt16(frameStart + 1))
				body.append(be16(UInt16(tileCount)))
				for index in 0..<tileCount {
					body.append(be16(UInt16(frameStart + index + 2)))
				}
				references.append(box("dimg", body))
			}
			frameStart += frame.count
		}
		if xmp != nil {
			var referenceBody = be16(metadataID)
			referenceBody.append(be16(1))
			referenceBody.append(be16(UInt16(primaryID)))
			references.append(box("cdsc", referenceBody))
		}
		if !references.isEmpty {
			references = fullBox("iref", version: 0,
								 flags: 0, body: references)
		}

		var mediaData = Data()
		var spans: [(UInt16, UInt64, UInt64)] = []
		if let xmp = xmp {
			mediaData = xmp
			spans.append((metadataID, 0, UInt64(xmp.count)))
		}
		for (index, image) in images.enumerated() {
			spans.append((UInt16(index + 1), UInt64(mediaData.count),
						  UInt64(image.bytes.count)))
			mediaData.append(image.bytes)
		}
		guard mediaData.count <= Int(UInt32.max) - 8 else {
			throw MuxError.overflow
		}

		let metaWithoutLocations = { (locations: Data) in
			var body = Data(repeating: 0, count: 4)
			body.append(handler)
			body.append(primary)
			body.append(locations)
			body.append(itemInfo)
			if !references.isEmpty { body.append(references) }
			body.append(iprp)
			return box("meta", body)
		}

		let placeholder = locationBox(spans, baseOffset: 0)
		let metaLength = metaWithoutLocations(placeholder).count
		let brand = images.contains(where: requiresExtendedBrand)
			? "heix" : "heic"
		let ftyp = box("ftyp", Data(brand.utf8)
					   + be32(0)
					   + Data(("mif1" + brand + "miaf").utf8))
		let mdatHeaderLength = 8
		let mediaDataOffset = UInt64(ftyp.count + metaLength + mdatHeaderLength)
		let locations = locationBox(spans, baseOffset: mediaDataOffset)
		var output = ftyp
		output.append(metaWithoutLocations(locations))
		output.append(box("mdat", mediaData))
		return output
	}

	private static func requiresExtendedBrand(_ image: ImageItem) -> Bool {
		guard let configuration = image.properties.first(where: {
			fourCC(boxType($0.box)) == "hvcC"
		}), configuration.box.count >= 27 else { return false }
		return configuration.box[24] != 1
			|| configuration.box[25] != 0
			|| configuration.box[26] != 0
	}

	private static func primaryItemID(_ data: Data, box: Box) throws -> UInt32 {
		guard box.end - box.payloadStart >= 6 else {
			throw MuxError.invalidFile
		}
		let version = data[box.payloadStart]
		let start = box.payloadStart + 4
		if version == 0 { return UInt32(try read16(data, at: start)) }
		if version == 1 { return try read32(data, at: start) }
		throw MuxError.unsupportedFile
	}

	private static func imageItemIDs(
		_ data: Data, box: Box
	) throws -> [UInt32] {
		guard box.end - box.payloadStart >= 6 else {
			throw MuxError.invalidFile
		}
		let version = data[box.payloadStart]
		let countStart = box.payloadStart + 4
		let count: Int
		let entryStart: Int
		if version == 0 {
			count = Int(try read16(data, at: countStart))
			entryStart = countStart + 2
		} else if version == 1 {
			count = Int(try read32(data, at: countStart))
			entryStart = countStart + 4
		} else {
			throw MuxError.unsupportedFile
		}
		let entries = try boxes(in: data, range: entryStart..<box.end)
		guard entries.count == count else { throw MuxError.invalidFile }
		var ids: [UInt32] = []
		for entry in entries where fourCC(entry.type) == "infe" {
			guard entry.end - entry.payloadStart >= 4 else {
				throw MuxError.invalidFile
			}
			let entryVersion = data[entry.payloadStart]
			let flags = try read24(data, at: entry.payloadStart + 1)
			if flags & 1 != 0 { continue }
			let start = entry.payloadStart + 4
			let id: UInt32
			let typeOffset: Int
			if entryVersion == 2 {
				guard entry.end - entry.payloadStart >= 12 else {
					throw MuxError.invalidFile
				}
				id = UInt32(try read16(data, at: start))
				typeOffset = start + 4
			} else if entryVersion == 3 {
				guard entry.end - entry.payloadStart >= 14 else {
					throw MuxError.invalidFile
				}
				id = try read32(data, at: start)
				typeOffset = start + 6
			} else {
				continue
			}
			let itemType = fourCC(data[typeOffset..<(typeOffset + 4)])
			if itemType == "hvc1" || itemType == "grid" { ids.append(id) }
		}
		return ids
	}

	private static func itemType(
		_ data: Data,
		box: Box,
		itemID: UInt32
	) throws -> String {
		guard box.end - box.payloadStart >= 6 else {
			throw MuxError.invalidFile
		}
		let version = data[box.payloadStart]
		let countStart = box.payloadStart + 4
		let count: Int
		let entryStart: Int
		if version == 0 {
			count = Int(try read16(data, at: countStart))
			entryStart = countStart + 2
		} else if version == 1 {
			count = Int(try read32(data, at: countStart))
			entryStart = countStart + 4
		} else { throw MuxError.unsupportedFile }

		let entries = try boxes(in: data, range: entryStart..<box.end)
		guard entries.count == count else { throw MuxError.invalidFile }
		for entry in entries where fourCC(entry.type) == "infe" {
			guard entry.end - entry.payloadStart >= 4 else {
				throw MuxError.invalidFile
			}
			let entryVersion = data[entry.payloadStart]
			let start = entry.payloadStart + 4
			let id: UInt32
			let typeOffset: Int
			if entryVersion == 2 {
				guard entry.end - entry.payloadStart >= 12 else {
					throw MuxError.invalidFile
				}
				id = UInt32(try read16(data, at: start))
				typeOffset = start + 4
			} else if entryVersion == 3 {
				guard entry.end - entry.payloadStart >= 14 else {
					throw MuxError.invalidFile
				}
				id = try read32(data, at: start)
				typeOffset = start + 6
			} else { continue }
			if id == itemID { return fourCC(data[typeOffset..<(typeOffset + 4)]) }
		}
		throw MuxError.invalidFile
	}

	private static func itemPayload(
		_ data: Data,
		box: Box,
		itemID: UInt32,
		idatStart: Int? = nil
	) throws -> Data {
		guard box.end - box.payloadStart >= 8 else {
			throw MuxError.invalidFile
		}
		let version = data[box.payloadStart]
		let sizes = data[box.payloadStart + 4]
		let offsetSize = Int(sizes >> 4)
		let lengthSize = Int(sizes & 0x0f)
		let baseSize = Int(data[box.payloadStart + 5] >> 4)
		let indexSize = version == 0 ? 0 : Int(data[box.payloadStart + 5] & 0x0f)
		guard [0, 4, 8].contains(offsetSize),
			  [0, 4, 8].contains(lengthSize),
			  [0, 4, 8].contains(baseSize),
			  version <= 2 else { throw MuxError.unsupportedFile }

		let cursor = Cursor(data: data, offset: box.payloadStart + 6,
						end: box.end)
		let count: UInt32
		if version == 2 {
			count = try cursor.read32()
		} else {
			count = UInt32(try cursor.read16())
		}
		guard count < 1_000_000 else { throw MuxError.invalidFile }
		for _ in 0..<count {
			let id: UInt32
			if version == 2 {
				id = try cursor.read32()
			} else {
				id = UInt32(try cursor.read16())
			}
			let method = version == 0 ? 0 : Int(try cursor.read16() & 0x0fff)
			let dataReference = try cursor.read16()
			let base = try cursor.readUInt(size: baseSize)
			let extentCount = try cursor.read16()
			var extents: [(UInt64, UInt64)] = []
			for _ in 0..<extentCount {
				if indexSize > 0 { _ = try cursor.readUInt(size: indexSize) }
				extents.append((try cursor.readUInt(size: offsetSize),
								try cursor.readUInt(size: lengthSize)))
			}
			let supportedMethod = method == 0
				|| method == 1 && idatStart != nil
			guard id != itemID || supportedMethod && dataReference == 0 else {
				if id == itemID { throw MuxError.unsupportedFile }
				continue
			}
			if id == itemID {
				var result = Data()
				for (offset, length) in extents {
					let position = base.addingReportingOverflow(offset)
					guard !position.overflow else {
						throw MuxError.invalidFile
					}
					let start64 = position.partialValue
						.addingReportingOverflow(UInt64(
							method == 1 ? idatStart ?? 0 : 0
						))
					guard !start64.overflow,
						  start64.partialValue <= UInt64(data.count) else {
						throw MuxError.invalidFile
					}
					let actualLength = length == 0
						? UInt64(data.count) - start64.partialValue
						: length
					let end = start64.partialValue.addingReportingOverflow(actualLength)
					guard !end.overflow, end.partialValue <= UInt64(data.count) else {
						throw MuxError.invalidFile
					}
					result.append(data[Int(start64.partialValue)..<Int(end.partialValue)])
				}
				guard !result.isEmpty else { throw MuxError.invalidFile }
				return result
			}
		}
		throw MuxError.invalidFile
	}

	private static func itemProperties(
		_ data: Data,
		box: Box,
		itemID: UInt32
	) throws -> [Property] {
		guard let container = try boxes(in: data,
										range: box.payloadStart..<box.end)
			.first(where: { fourCC($0.type) == "ipco" }),
			  let associations = try boxes(in: data,
											   range: box.payloadStart..<box.end)
				.first(where: { fourCC($0.type) == "ipma" }) else {
			throw MuxError.invalidFile
		}
		let propertyBoxes = try boxes(in: data,
									  range: container.payloadStart..<container.end)
		guard associations.end - associations.payloadStart >= 8 else {
			throw MuxError.invalidFile
		}
		let version = data[associations.payloadStart]
		guard version <= 1 else { throw MuxError.unsupportedFile }
		let flags = try read24(data, at: associations.payloadStart + 1)
		let wideIndices = flags & 1 != 0
		let cursor = Cursor(data: data,
						offset: associations.payloadStart + 4,
						end: associations.end)
		let count = try cursor.read32()
		guard count < 1_000_000 else { throw MuxError.invalidFile }
		for _ in 0..<count {
			let id = version < 1
				? UInt32(try cursor.read16())
				: try cursor.read32()
			let associationCount = Int(try cursor.read8())
			var properties: [Property] = []
			for _ in 0..<associationCount {
				let value = wideIndices
					? try cursor.read16()
					: UInt16(try cursor.read8())
				let essential = wideIndices ? value & 0x8000 != 0
					: value & 0x80 != 0
				let index = Int(wideIndices ? value & 0x7fff : value & 0x7f)
				guard index > 0, index <= propertyBoxes.count else {
					throw MuxError.invalidFile
				}
				if id == itemID {
					let property = propertyBoxes[index - 1]
					let propertyData = Data(data[property.start..<property.end])
					if fourCC(property.type) == "auxC" {
						throw MuxError.unsupportedFile
					}
					properties.append(Property(box: propertyData,
											   essential: essential))
				}
			}
			if id == itemID { return properties }
		}
		throw MuxError.invalidFile
	}

	private static func hasUnsupportedReferences(
		_ data: Data,
		box: Box,
		primaryID: UInt32
	) throws -> Bool {
		guard box.end - box.payloadStart >= 4 else {
			throw MuxError.invalidFile
		}
		let version = data[box.payloadStart]
		guard version <= 1 else { throw MuxError.unsupportedFile }
		let references = try boxes(in: data,
								   range: (box.payloadStart + 4)..<box.end)
		for reference in references {
			let cursor = Cursor(data: data, offset: reference.payloadStart,
						end: reference.end)
			let from: UInt32
			if version == 0 {
				from = UInt32(try cursor.read16())
			} else {
				from = try cursor.read32()
			}
			let count = try cursor.read16()
			var targets: [UInt32] = []
			for _ in 0..<count {
				if version == 0 {
					targets.append(UInt32(try cursor.read16()))
				} else {
					targets.append(try cursor.read32())
				}
			}
			if from == primaryID || targets.contains(primaryID) {
				let type = fourCC(reference.type)
				if type == "cdsc" { continue }
				if type == "thmb" && from != primaryID { continue }
				return true
			}
		}
		return false
	}

	private static func locationBox(
		_ spans: [(UInt16, UInt64, UInt64)],
		baseOffset: UInt64
	) -> Data {
		var body = Data([0x88, 0x00])
		body.append(be16(UInt16(spans.count)))
		for (id, offset, length) in spans {
			body.append(be16(id))
			body.append(be16(0))
			body.append(be16(0))
			body.append(be16(1))
			body.append(be64(baseOffset + offset))
			body.append(be64(length))
		}
		return fullBox("iloc", version: 1, flags: 0, body: body)
	}

	private static func boxes(in data: Data, range: Range<Int>) throws -> [Box] {
		guard range.lowerBound >= 0, range.upperBound <= data.count else {
			throw MuxError.invalidFile
		}
		var result: [Box] = []
		var offset = range.lowerBound
		while offset < range.upperBound {
			guard range.upperBound - offset >= 8 else { throw MuxError.invalidFile }
			let size32 = try read32(data, at: offset)
			let type = data[(offset + 4)..<(offset + 8)]
			var headerSize = 8
			let size: UInt64
			if size32 == 1 {
				size = try read64(data, at: offset + 8)
				headerSize = 16
			} else if size32 == 0 {
				size = UInt64(range.upperBound - offset)
			} else {
				size = UInt64(size32)
			}
			guard size >= UInt64(headerSize),
				  size <= UInt64(range.upperBound - offset) else {
				throw MuxError.invalidFile
			}
			let end = offset + Int(size)
			result.append(Box(type: type, start: offset,
							  payloadStart: offset + headerSize, end: end))
			offset = end
		}
		return result
	}

	private static func boxType(_ data: Data) -> Data {
		guard data.count >= 8 else { return Data() }
		return data[4..<8]
	}

	private static func box(_ type: String, _ body: Data) -> Data {
		var result = be32(UInt32(body.count + 8))
		result.append(Data(type.utf8))
		result.append(body)
		return result
	}

	private static func fullBox(
		_ type: String,
		version: UInt8,
		flags: UInt32,
		body: Data
	) -> Data {
		var payload = Data([version])
		payload.append(UInt8((flags >> 16) & 0xff))
		payload.append(UInt8((flags >> 8) & 0xff))
		payload.append(UInt8(flags & 0xff))
		payload.append(body)
		return box(type, payload)
	}

	private static func fourCC<S: Collection>(_ data: S) -> String
	where S.Element == UInt8 {
		String(bytes: data, encoding: .ascii) ?? ""
	}

	private static func be16(_ value: UInt16) -> Data {
		Data([UInt8(value >> 8), UInt8(value & 0xff)])
	}

	private static func be32(_ value: UInt32) -> Data {
		Data([UInt8(value >> 24), UInt8((value >> 16) & 0xff),
			  UInt8((value >> 8) & 0xff), UInt8(value & 0xff)])
	}

	private static func be64(_ value: UInt64) -> Data {
		var result = Data()
		for shift in stride(from: 56, through: 0, by: -8) {
			result.append(UInt8((value >> UInt64(shift)) & 0xff))
		}
		return result
	}

	private static func read16(_ data: Data, at offset: Int) throws -> UInt16 {
		guard offset >= 0, offset <= data.count - 2 else {
			throw MuxError.invalidFile
		}
		return UInt16(data[offset]) << 8 | UInt16(data[offset + 1])
	}

	private static func read24(_ data: Data, at offset: Int) throws -> UInt32 {
		guard offset >= 0, offset <= data.count - 3 else {
			throw MuxError.invalidFile
		}
		return UInt32(data[offset]) << 16 | UInt32(data[offset + 1]) << 8
			| UInt32(data[offset + 2])
	}

	private static func read32(_ data: Data, at offset: Int) throws -> UInt32 {
		guard offset >= 0, offset <= data.count - 4 else {
			throw MuxError.invalidFile
		}
		return UInt32(data[offset]) << 24 | UInt32(data[offset + 1]) << 16
			| UInt32(data[offset + 2]) << 8 | UInt32(data[offset + 3])
	}

	private static func read64(_ data: Data, at offset: Int) throws -> UInt64 {
		guard offset >= 0, offset <= data.count - 8 else {
			throw MuxError.invalidFile
		}
		var value: UInt64 = 0
		for index in 0..<8 { value = (value << 8) | UInt64(data[offset + index]) }
		return value
	}

	private final class Cursor {
		private let data: Data
		private var offset: Int

		private let end: Int

		init(data: Data, offset: Int, end: Int) {
			self.data = data
			self.offset = offset
			self.end = end
		}

		func read8() throws -> UInt8 {
			guard offset < end else { throw MuxError.invalidFile }
			defer { offset += 1 }
			return data[offset]
		}

		func read16() throws -> UInt16 {
			guard offset <= end - 2 else { throw MuxError.invalidFile }
			defer { offset += 2 }
			return try HEIFMuxer.read16(data, at: offset)
		}

		func read32() throws -> UInt32 {
			guard offset <= end - 4 else { throw MuxError.invalidFile }
			defer { offset += 4 }
			return try HEIFMuxer.read32(data, at: offset)
		}

		func readUInt(size: Int) throws -> UInt64 {
			guard [0, 4, 8].contains(size) else { throw MuxError.unsupportedFile }
			if size == 0 { return 0 }
			let value = size == 4
				? UInt64(try read32()) : try read64()
			return value
		}

		private func read64() throws -> UInt64 {
			guard offset <= end - 8 else { throw MuxError.invalidFile }
			defer { offset += 8 }
			return try HEIFMuxer.read64(data, at: offset)
		}
	}
}
