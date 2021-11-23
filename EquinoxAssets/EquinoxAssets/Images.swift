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

import AppKit

// swiftlint:disable force_unwrapping

public enum Image {
    public static let images = Bundler.current.bundle.image(forResource: "Images")!
    public static let copy = Bundler.current.bundle.image(forResource: "Copy")!
    public static let drag = Bundler.current.bundle.image(forResource: "Drag")!
    public static let location = Bundler.current.bundle.image(forResource: "Location")!
    public static let pin = Bundler.current.bundle.image(forResource: "Pin")!
    public static let solar = Bundler.current.bundle.image(forResource: "Solar")!
    public static let time = Bundler.current.bundle.image(forResource: "Time")!
    public static let appearance = Bundler.current.bundle.image(forResource: "Appearance")!
    public static let back = Bundler.current.bundle.image(forResource: "Back")!
    public static let set = Bundler.current.bundle.image(forResource: "Set")!
    public static let file = Bundler.current.bundle.image(forResource: "File")!
    public static let cancel = Bundler.current.bundle.image(forResource: "Cancel")!
    public static let save = Bundler.current.bundle.image(forResource: "Save")!
    public static let icon = Bundler.current.bundle.image(forResource: "Icon")!
    public static let share = Bundler.current.bundle.image(forResource: "Share")!
    public static let solarTip = Bundler.current.bundle.image(forResource: "SolarTip")!
    public static let timeTip = Bundler.current.bundle.image(forResource: "TimeTip")!
    public static let appearanceTip = Bundler.current.bundle.image(forResource: "AppearanceTip")!
    public static let calculatorTip = Bundler.current.bundle.image(forResource: "CalculatorTip")!
    public static let setTip = Bundler.current.bundle.image(forResource: "SetTip")!
}

// swiftlint:enable force_unwrapping
