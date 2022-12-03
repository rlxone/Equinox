// Copyright (c) 2021 Dmitry Meduho
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import EquinoxCore
import XCTest

class StorageCoreTests: XCTestCase {
    private var storageCore: StorageCore!
    private var userDefaults: MockUserDefaults!
    
    override func setUpWithError() throws {
        userDefaults = MockUserDefaults()
        storageCore = StorageCoreImpl(userDefaults: userDefaults)
    }
    
    func testSetGet() throws {
        // Given
        let key1 = "key1"
        let key2 = "key2"
        let key3 = "key3"
        let value1 = "data1"
        let value2 = "data2"
        let value3 = "data3"
        
        // When
        storageCore.set(key: key1, value: value1)
        storageCore.set(key: key2, value: value2)
        storageCore.set(key: key3, value: value3)
        
        let result1: String = try XCTUnwrap(try? storageCore.get(key: key1))
        let result2: String = try XCTUnwrap(try? storageCore.get(key: key2))
        let result3: String = try XCTUnwrap(try? storageCore.get(key: key3))
        
        // Then
        XCTAssertEqual(value1, result1)
        XCTAssertEqual(value2, result2)
        XCTAssertEqual(value3, result3)
    }
    
    func testRemove() {
        // Given
        let key1 = "key1"
        let key2 = "key2"
        let key3 = "key3"
        let value1 = "data1"
        let value2 = "data2"
        let value3 = "data3"
        
        // When
        storageCore.set(key: key1, value: value1)
        storageCore.set(key: key2, value: value2)
        storageCore.set(key: key3, value: value3)
        
        storageCore.remove(key: key1)
        storageCore.remove(key: key2)
        storageCore.remove(key: key3)
        
        let result1: String? = try? storageCore.get(key: key1)
        let result2: String? = try? storageCore.get(key: key2)
        let result3: String? = try? storageCore.get(key: key3)
        
        // Then
        XCTAssertNil(result1)
        XCTAssertNil(result2)
        XCTAssertNil(result3)
    }
}
