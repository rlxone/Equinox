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

import Foundation

public enum Localization {
    public enum Shared {
        public static func images(param1: Int) -> String {
            return String(format: Localization.localizedString(key: "images"), arguments: [param1])
        }
    }
    
    public enum Menu {
        public enum Main {
            public static func about(param1: String) -> String {
                return String(format: Localization.localizedString(key: "menu.main.about"), arguments: [param1])
            }
            public static func hide(param1: String) -> String {
                return String(format: Localization.localizedString(key: "menu.main.hide"), arguments: [param1])
            }
            public static func quit(param1: String) -> String {
                return String(format: Localization.localizedString(key: "menu.main.quit"), arguments: [param1])
            }
            
            public static let preferences = Localization.localizedString(key: "menu.main.preferences")
            public static let hideOthers = Localization.localizedString(key: "menu.main.hide.others")
            public static let showAll = Localization.localizedString(key: "menu.main.show.all")
        }
        
        public enum File {
            public static let file = Localization.localizedString(key: "menu.file")
            public static let new = Localization.localizedString(key: "menu.file.new")
        }
        
        public enum Edit {
            public static let edit = Localization.localizedString(key: "menu.edit")
            public static let undo = Localization.localizedString(key: "menu.edit.undo")
            public static let redo = Localization.localizedString(key: "menu.edit.redo")
            public static let cut = Localization.localizedString(key: "menu.edit.cut")
            public static let copy = Localization.localizedString(key: "menu.edit.copy")
            public static let paste = Localization.localizedString(key: "menu.edit.paste")
            public static let selectAll = Localization.localizedString(key: "menu.edit.select.all")
            public static let delete = Localization.localizedString(key: "menu.edit.delete")
        }
        
        public enum Window {
            public static let window = Localization.localizedString(key: "menu.window")
            public static let minimize = Localization.localizedString(key: "menu.window.minimize")
            public static let zoom = Localization.localizedString(key: "menu.window.zoom")
            public static let showAll = Localization.localizedString(key: "menu.window.show.all")
        }
        
        public enum Help {
            public static let help = Localization.localizedString(key: "menu.help")
            public static let githubProject = Localization.localizedString(key: "menu.help.githubProject")
            public static let githubFAQ = Localization.localizedString(key: "menu.help.githubFAQ")
            public static let githubIssue = Localization.localizedString(key: "menu.help.githubIssue")
            public static let equinoxWebsite = Localization.localizedString(key: "menu.help.equinoxWebsite")
            public static let macAppStoreReview = Localization.localizedString(key: "menu.help.macAppStoreReview")
            public static let productHunt = Localization.localizedString(key: "menu.help.productHunt")
        }
    }
    
    public enum Dock {
        public static let new = Localization.localizedString(key: "dock.new")
    }
    
    public enum Welcome {
        public static func welcome(param1: String) -> String {
            return String(format: Localization.localizedString(key: "welcome.welcome"), arguments: [param1])
        }
        public static func version(param1: String) -> String {
            return String(format: Localization.localizedString(key: "welcome.version"), arguments: [param1])
        }
        
        public static let title = Localization.localizedString(key: "welcome.title")
        public static let github = Localization.localizedString(key: "welcome.github")
        public static let choose = Localization.localizedString(key: "welcome.choose.type")
        public static let select = Localization.localizedString(key: "welcome.choose.type.description")
        public static let solar = Localization.localizedString(key: "welcome.types.solar")
        public static let solarDescription = Localization.localizedString(key: "welcome.types.solar.description")
        public static let time = Localization.localizedString(key: "welcome.types.time")
        public static let timeDescription = Localization.localizedString(key: "welcome.types.time.description")
        public static let appearance = Localization.localizedString(key: "welcome.types.appearance")
        public static let appearanceDescription = Localization.localizedString(key: "welcome.types.appearance.description")
    }
    
    public enum Wallpaper {
        public enum Main {
            public static let solar = Localization.localizedString(key: "wallpaper.main.solar")
            public static let time = Localization.localizedString(key: "wallpaper.main.time")
            public static let appearance = Localization.localizedString(key: "wallpaper.main.appearance")
            public static let calculator = Localization.localizedString(key: "wallpaper.main.calculator")
            public static let create = Localization.localizedString(key: "wallpaper.main.create")
            public static let browse = Localization.localizedString(key: "wallpaper.main.browse")
            public static let validate = Localization.localizedString(key: "wallpaper.main.validate")
        }
        
        public enum Gallery {
            public static func menuDelete(param1: Int) -> String {
                return String(format: Localization.localizedString(key: "delete"), arguments: [param1])
            }
            
            public static func wrongImagesType(param1: Int) -> String {
                return String(format: Localization.localizedString(key: "wallpaper.gallery.wrong.images.type"), arguments: [param1])
            }
            
            public static let dragTitle = Localization.localizedString(key: "wallpaper.gallery.drag.title")
            public static let dragSupplementary = Localization.localizedString(key: "wallpaper.gallery.drag.supplementary")
            public static let or = Localization.localizedString(key: "wallpaper.gallery.or")
            public static let browse = Localization.localizedString(key: "wallpaper.gallery.browse")
            public static let azimuth = Localization.localizedString(key: "wallpaper.gallery.azimuth")
            public static let azimuthValue = Localization.localizedString(key: "wallpaper.gallery.azimuth.value")
            public static let altitude = Localization.localizedString(key: "wallpaper.gallery.altitude")
            public static let altitudeValue = Localization.localizedString(key: "wallpaper.gallery.azimuth.value")
            public static let time = Localization.localizedString(key: "wallpaper.gallery.time")
            public static let tooltipAppearanceTitle = Localization.localizedString(key: "wallpaper.gallery.tooltip.appearance.title")
            public static let tooltipAppearanceDescription = Localization.localizedString(key: "wallpaper.gallery.tooltip.appearance.description")
            public static let tooltipPrimaryTitle = Localization.localizedString(key: "wallpaper.gallery.tooltip.primary.title")
            public static let tooltipPrimaryDescription = Localization.localizedString(key: "wallpaper.gallery.tooltip.primary.description")
        }
        
        public enum Appearance {
            public static let autoTitle = Localization.localizedString(key: "wallpaper.appearance.auto.title")
            public static let autoDescription = Localization.localizedString(key: "wallpaper.appearance.auto.description")
            public static let lightTitle = Localization.localizedString(key: "wallpaper.appearance.light.title")
            public static let lightDescription = Localization.localizedString(key: "wallpaper.appearance.light.description")
            public static let darkTitle = Localization.localizedString(key: "wallpaper.appearance.dark.title")
            public static let darkDescription = Localization.localizedString(key: "wallpaper.appearance.dark.description")
        }
        
        public enum Create {
            public static let success = Localization.localizedString(key: "wallpaper.create.success")
            public static let successDescription = Localization.localizedString(key: "wallpaper.create.success.description")
            public static let failure = Localization.localizedString(key: "wallpaper.create.failure")
            public static let failureDescription = Localization.localizedString(key: "wallpaper.create.failure.description")
            public static let save = Localization.localizedString(key: "wallpaper.create.save")
            public static let set = Localization.localizedString(key: "wallpaper.create.set")
            public static let new = Localization.localizedString(key: "wallpaper.create.new")
            public static let cancel = Localization.localizedString(key: "wallpaper.create.cancel")
            public static let share = Localization.localizedString(key: "wallpaper.create.share")
            public static let solarBased = Localization.localizedString(key: "wallpaper.create.solar.based")
            public static let timeBased = Localization.localizedString(key: "wallpaper.create.time.based")
            public static let appearanceBased = Localization.localizedString(key: "wallpaper.create.appearance.based")
            public static let fileSaved = Localization.localizedString(key: "wallpaper.create.file.saved")
            public static let newTitle = Localization.localizedString(key: "wallpaper.create.new.title")
            public static let newDescription = Localization.localizedString(key: "wallpaper.create.new.description")
            public static let create = Localization.localizedString(key: "wallpaper.create.title")
            public static let `repeat` = Localization.localizedString(key: "wallpaper.create.repeat.title")
            public static let setError = Localization.localizedString(key: "wallpaper.create.set.error")
            public static let setSuccess = Localization.localizedString(key: "wallpaper.create.set.success")
            public static let cantShare = Localization.localizedString(key: "wallpaper.create.cant.share")
        }
        
        public enum Set {
            public static let title = Localization.localizedString(key: "wallpaper.set.title")
            public static let descriptionTitleOld = Localization.localizedString(key: "wallpaper.set.description.title.old")
            public static let todoOld = Localization.localizedString(key: "wallpaper.set.todo.old")
            public static let todoLinkOld = Localization.localizedString(key: "wallpaper.set.todo.link.old")
            public static let descriptionTitle = Localization.localizedString(key: "wallpaper.set.description.title")
            public static let todo = Localization.localizedString(key: "wallpaper.set.todo")
            public static let todoLink = Localization.localizedString(key: "wallpaper.set.todo.link")
            public static let `continue` = Localization.localizedString(key: "wallpaper.set.continue")
            public static let skip = Localization.localizedString(key: "wallpaper.set.skip")
        }
    }
    
    public enum Solar {
        public enum Main {
            public static let title = Localization.localizedString(key: "solar.main.title")
            public static let locationHeader = Localization.localizedString(key: "solar.main.location.header")
            public static let dateHeader = Localization.localizedString(key: "solar.main.date.header")
            public static let resultHeader = Localization.localizedString(key: "solar.main.result.header")
            public static let latitude = Localization.localizedString(key: "solar.main.latitude")
            public static let longitude = Localization.localizedString(key: "solar.main.longitude")
            public static let date = Localization.localizedString(key: "solar.main.date")
            public static let altitude = Localization.localizedString(key: "solar.main.altitude")
            public static let azimuth = Localization.localizedString(key: "solar.main.azimuth")
            public static let value = Localization.localizedString(key: "solar.main.value")
            public static let copied = Localization.localizedString(key: "solar.main.copied")
            public static let sunTimeline = Localization.localizedString(key: "solar.main.sun.timeline")
            public static let timezone = Localization.localizedString(key: "solar.main.timezone")
            public static let locationError = Localization.localizedString(key: "solar.main.location.error")
            public static let daylightSavingTimeTitle = Localization.localizedString(key: "solar.main.dst.title")
            public static let daylightSavingTimeTooltipTitle = Localization.localizedString(key: "solar.main.dst.tooltip.title")
            public static let daylightSavingTimeTooltipDescription = Localization.localizedString(key: "solar.main.dst.tooltip.description")
            public static let abbreviationTooltipTitle = Localization.localizedString(key: "solar.main.abbreviation.tooltip.title")
            public static let abbreviationTooltipDescription = Localization.localizedString(key: "solar.main.abbreviation.tooltip.description")
            public static let dragAndDropTooltipTitle = Localization.localizedString(key: "solar.main.drag.and.drop.tooltip.title")
            public static let dragAndDropTooltipDescription = Localization.localizedString(key: "solar.main.drag.and.drop.tooltip.description")
        }
    }
    
    public enum Tip {
        public enum Shared {
            public static let tips = Localization.localizedString(key: "tip.tips")
            public static let started = Localization.localizedString(key: "tip.started")
            public static let ok = Localization.localizedString(key: "tip.ok")
        }
        
        public enum Solar {
            public static let title = Localization.localizedString(key: "tip.solar.title")
            public static let description = Localization.localizedString(key: "tip.solar.description")
        }
        
        public enum Time {
            public static let title = Localization.localizedString(key: "tip.time.title")
            public static let description = Localization.localizedString(key: "tip.time.description")
        }
        
        public enum Appearance {
            public static let title = Localization.localizedString(key: "tip.appearance.title")
            public static let description = Localization.localizedString(key: "tip.appearance.description")
        }
        
        public enum Calculator {
            public static let title = Localization.localizedString(key: "tip.calculator.title")
            public static let description = Localization.localizedString(key: "tip.calculator.description")
        }
    }
}

// MARK: - Localization

extension Localization {
    private static func localizedString(key: String) -> String {
        return NSLocalizedString(key, tableName: nil, bundle: Bundler.current.bundle, value: String(), comment: String())
    }
}
