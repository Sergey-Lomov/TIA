//
//  ComplexCurve.swift
//  TIA
//
//  Created by Serhii.Lomov on 18.04.2022.
//

import Foundation
import SwiftUI

struct ComplexCurve {
    static let empty = ComplexCurve(components: [])
    
    var components: [BezierCurve]
}

extension ComplexCurve: VectorArithmetic {
    static func - (lhs: ComplexCurve, rhs: ComplexCurve) -> ComplexCurve {
        let curves = lhs.components.merged(with: rhs.components) { $0 - $1 }
        return ComplexCurve(components: curves)
    }
    
    static func + (lhs: ComplexCurve, rhs: ComplexCurve) -> ComplexCurve {
        let curves = lhs.components.merged(with: rhs.components) { $0 + $1 }
        return ComplexCurve(components: curves)
    }
    
    mutating func scale(by rhs: Double) {
        components.scale(by: rhs)
    }
    
    var magnitudeSquared: Double {
        components.magnitudeSquared
    }
    
    static var zero: ComplexCurve {
        .empty
    }
}

extension ComplexCurve {
    private static let cirleControlCoefficient: CGFloat = 0.66666
    
    static func circle(radius: CGFloat) -> ComplexCurve {
        let control = radius * 2 * cirleControlCoefficient
        let components = [
            BezierCurve(points: [
                CGPoint(x: 0, y: radius),
                CGPoint(x: -1 * control, y: radius),
                CGPoint(x: -1 * control, y: -1 * radius),
                CGPoint(x: 0, y: -1 * radius),
            ]),
            BezierCurve(points: [
                CGPoint(x: 0, y: -1 * radius),
                CGPoint(x: control, y: -1 * radius),
                CGPoint(x: control, y: radius),
                CGPoint(x: 0, y: radius),
            ]),
        ]
        
        return ComplexCurve(components: components)
    }
}
