//
//  ColorSchema.swift
//  TIA
//
//  Created by Serhii.Lomov on 20.04.2022.
//

import SwiftUI

struct ColorSchema {
    let background: Color
    let vertex: Color
    let edge: Color
    let resources: Color
    let resourcesBorder: Color
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
                                  edge: .softWhite,
                                  resources: .softWhite,
                                  resourcesBorder: .softBlack,
                                  player: .softBlack)
    
    static let light = ColorSchema(background: .softWhite,
                                   vertex: .softBlack,
                                   edge: .softBlack,
                                   resources: .softBlack,
                                   resourcesBorder: .softWhite,
                                   player: .softWhite)
    
    static let truth = ColorSchema(background: .softBlack,
                                   vertex: .softWhite,
                                   edge: .softWhite,
                                   resources: .softWhite,
                                   resourcesBorder: .softBlack,
                                   player: .softBlack)
}
