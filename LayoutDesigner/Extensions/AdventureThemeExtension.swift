//
//  AdventureThemeExtension.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 14.07.2022.
//

import SwiftUI

extension AdventureTheme {
    var selectionColor: Color {
        switch self {
        case .dark: return Color(hex: 0x51BDDA)
        case .light: return Color(hex: 0x2DAF4F)
        case .truth: return Color(hex: 0x51BDDA)
        }
    }
}
