//
//  Colors.swift
//  TIA
//
//  Created by Serhii.Lomov on 06.04.2022.
//

import Foundation
import SwiftUI

// swiftlint:disable numbers_smell
extension Color {

    init(hex: UInt, alpha: Double = 1) {
        let red = Double((hex >> 16) & 0xff) / 255
        let green = Double((hex >> 8) & 0xff) / 255
        let blue = Double(hex & 0xff) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    static func random(min: UInt = 50, max: UInt = 255) -> Color {
        let range = min...max
        let r = Double(range.randomElement() ?? 0) / 255
        let g = Double(range.randomElement() ?? 0) / 255
        let b = Double(range.randomElement() ?? 0) / 255
        return Color(red: r, green: g, blue: b)
    }
}
// swiftlint:enable numbers_smell

extension Color {
    static let softBlack = Color(hex: 0x181A18)
    static let softWhite = Color(hex: 0xFBFAF5)
}
