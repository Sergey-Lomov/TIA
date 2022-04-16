//
//  Colors.swift
//  TIA
//
//  Created by Serhii.Lomov on 06.04.2022.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
extension Color {
    static let softBlack = Color(hex: 0x181A18)
    static let softWhite = Color(hex: 0xFBFAF5)
    
    static func mainFor(_ theme: AdventureTheme) -> Color {
        switch theme {
        case .dark:
            return softBlack
        case .light:
            return softWhite
        case .truth:
            return softBlack
        }
    }
    
    static func inversedFor(_ theme: AdventureTheme) -> Color {
        switch theme {
        case .dark:
            return softWhite
        case .light:
            return softBlack
        case .truth:
            return softWhite
        }
    }
}
