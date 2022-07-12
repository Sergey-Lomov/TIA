//
//  Path.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import SwiftUI

extension Path {

    static func line(from: CGPoint, to: CGPoint) -> Path {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        return path
    }

    init (curves: [BezierCurve], size: CGSize? = nil, close: Bool = false) {
        self.init()

        for curve in curves {
            var normalizedCurve = curve
            if let size = size {
                normalizedCurve = curve
                    .scaled(size)
                    .translated(x: size.width / 2, y: size.height / 2)
            }

            addCurve(normalizedCurve)
        }

        if close {
            closeSubpath()
        }
    }

    init (curve: BezierCurve, size: CGSize? = nil) {
        self.init(curves: [curve], size: size)
    }

    init(curve: BezierCurve, geometry: GeometryProxy) {
        self.init(curve: curve, size: geometry.size)
    }

    mutating func addCurve(_ curve: BezierCurve) {
        if currentPoint == nil { move(to: curve.from) }
        addCurve(to: curve.to, control1: curve.control1, control2: curve.control2)
    }
}
