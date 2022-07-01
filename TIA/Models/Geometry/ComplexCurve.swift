//
//  ComplexCurve.swift
//  TIA
//
//  Created by Serhii.Lomov on 18.04.2022.
//

import Foundation
import SwiftUI

struct ComplexCurve {
    private static let lengthSteps: Int = 100

    static let empty = ComplexCurve([])

    var components: [BezierCurve]

    static func onePoint(_ point: CGPoint) -> ComplexCurve {
        .init(.onePoint(point))
    }

    static func line(from: CGPoint, to: CGPoint) -> ComplexCurve {
        .init(.line(from: from, to: to))
    }

    static func poly(_ sides: Int) -> ComplexCurve {
        var components: [BezierCurve] = []
        for i in 0..<sides {
            let a1 = CGFloat(i) * .dpi / CGFloat(sides)
            let a2 = CGFloat(i + 1) * .dpi / CGFloat(sides)
            let p1 = CGPoint(angle: a1)
            let p2 = CGPoint(angle: a2)
            components.append(.line(from: p1, to: p2))
        }
        return .init(components).scaled(0.5)
    }

    static func start(_ rays: Int, deep: CGFloat, rayAlignment: Bool = true) -> ComplexCurve {
        var components: [BezierCurve] = []
        for i in 0..<rays {
            let delta = rayAlignment ? .pi / CGFloat(rays) : 0
            let a1 = CGFloat(i) * .dpi / CGFloat(rays) + delta
            let a2 = CGFloat(i + 1) * .dpi / CGFloat(rays) + delta
            let ma = (a1 + a2) / 2
            let p1 = CGPoint(angle: a1, radius: 1 - deep)
            let mp = CGPoint(angle: ma)
            let p2 = CGPoint(angle: a2, radius: 1 - deep)
            components.append(.line(from: p1, to: mp))
            components.append(.line(from: mp, to: p2))
        }
        return .init(components).scaled(0.5)
    }

    init(_ components: [BezierCurve]) {
        self.components = components
    }

    init(_ component: BezierCurve) {
        self.components = [component]
    }

    init(points: [CGPoint]) {
        self.components = [.init(points: points)]
    }

    func scaled(_ scale: CGFloat) -> ComplexCurve {
        return scaled(x: scale, y: scale)
    }

    func scaled(x: CGFloat, y: CGFloat) -> ComplexCurve {
        let components = self.components.map { $0.scaled(x: x, y: y) }
        return .init(components)
    }

    func reversed() -> ComplexCurve {
        let components = self.components.map { $0.reversed() }
        return .init(components.reversed())
    }

    func length(stepsCount: Int = Self.lengthSteps) -> CGFloat {
        let lengths = components.map { $0.length(stepsCount: stepsCount) }
        return lengths.reduce(0, +)
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

    static func circle(radius: CGFloat, componentsCount: Int = 4) -> ComplexCurve {
        var components: [BezierCurve] = []
        let step = CGFloat.dpi / CGFloat(componentsCount)
        for i in 0..<componentsCount {
            let from = CGFloat(i) * step
            let to = CGFloat(i + 1) * step
            let arc = BezierCurve.arc(from: from, to: to)
            components.append(arc.scaled(radius))
        }
        return ComplexCurve(components)
    }
}
