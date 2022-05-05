//
//  ComplexCurve.swift
//  TIA
//
//  Created by Serhii.Lomov on 18.04.2022.
//

import Foundation
import SwiftUI

struct ComplexCurve {
    static let empty = ComplexCurve([])
        
    var components: [BezierCurve]
    
    init(_ components: [BezierCurve]) {
        self.components = components
    }
    
    init(_ component: BezierCurve) {
        self.components = [component]
    }
    
    init(points: [CGPoint]) {
        self.components = [.init(points: points)]
    }
    
    func scaled(x: CGFloat, y: CGFloat) -> ComplexCurve {
        let components = self.components.map { $0.scaled(x: x, y: y) }
        return .init(components)
    }
    
    func reversed() -> ComplexCurve {
        let components = self.components.map { $0.reversed() }
        return .init(components.reversed())
    }
}

extension ComplexCurve: VectorArithmetic {
    static func - (lhs: ComplexCurve, rhs: ComplexCurve) -> ComplexCurve {
        let curves = lhs.components.merged(with: rhs.components) { $0 - $1 }
        return ComplexCurve(curves)
    }
    
    static func + (lhs: ComplexCurve, rhs: ComplexCurve) -> ComplexCurve {
        let curves = lhs.components.merged(with: rhs.components) { $0 + $1 }
        return ComplexCurve(curves)
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
        
        return ComplexCurve(components)
    }
}
