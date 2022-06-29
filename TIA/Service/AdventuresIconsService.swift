//
//  AdventuresIconsService.swift
//  TIA
//
//  Created by serhii.lomov on 28.06.2022.
//

import CoreGraphics

final class AdventuresIconsService {

    private static let starsDeep: CGFloat = 0.5
    
    static func curveFor(_ shape: AdventureDoneShape) -> ComplexCurve {
        switch shape {
        case .star8:
            return .start(8, deep: 0.3)
        case .poly7:
            return .poly(7)
        }
    }
}
