//
//  ColorSchema.swift
//  TIA
//
//  Created by Serhii.Lomov on 20.04.2022.
//

import SwiftUI

// TODO: rename to avoid mismatch with SwiftUI ColorShemE type
struct ColorSchema {
    let background: Color
    let vertex: Color
    let vertexElements: Color
    let edge: Color
    let resources: Color
    let borders: Color
    let player: Color
    
    static func schemaFor(_ theme: AdventureTheme) -> ColorSchema {
        switch theme {
        case .dark:
            return dark
        case .light:
            return light
        case .truth:
            return truth
        }
    }
    
    static let dark = ColorSchema(background: .softBlack,
                                  vertex: .softWhite,
                                  vertexElements: .softBlack,
                                  edge: .softWhite,
                                  resources: .softWhite,
                                  borders: .softBlack,
                                  player: .softBlack)
    
    static let light = ColorSchema(background: .softWhite,
                                   vertex: .softBlack,
                                   vertexElements: .softWhite,
                                   edge: .softBlack,
                                   resources: .softBlack,
                                   borders: .softWhite,
                                   player: .softWhite)
    
    static let truth = ColorSchema(background: .softBlack,
                                   vertex: .softWhite,
                                   vertexElements: .softBlack,
                                   edge: .softWhite,
                                   resources: .softWhite,
                                   borders: .softBlack,
                                   player: .softBlack)
}
