//
//  CGPoint.swift
//  TIA
//
//  Created by Serhii.Lomov on 10.04.2022.
//

import CoreGraphics
import SwiftUI

extension CGPoint {
    func multedPoint(x mx: CGFloat, y my: CGFloat) -> CGPoint {
        CGPoint(x: x * mx, y: y * my)
    }
    
    func translatedPoint(x dx: CGFloat, y dy: CGFloat) -> CGPoint {
        CGPoint(x: x + dx, y: y + dy)
    }
    
    func mirroredByLine(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return mirroredByLine(Line(p1: p1, p2: p2))
    }
    
    func randomPoint(maxDelta: CGFloat) -> CGPoint {
        let rx = CGFloat.random(in: (x - maxDelta)...(x + maxDelta))
        let ry = CGFloat.random(in: (y - maxDelta)...(y + maxDelta))
//        let ry = CGFloat.random(max: y + maxDelta, min: y - maxDelta)
        return CGPoint(x: rx, y: ry)
    }
    
    func mirroredByLine(_ l: Line) -> CGPoint {
        let _c = y - l.b / l.a * x
        let xm = -1 * (l.c + l.b * _c) / (l.a + l.b * l.b / l.a)
        let ym = l.b / l.a * xm + _c
        let xr = 2 * xm - x
        let yr = 2 * ym - y
        return CGPoint(x: xr, y: yr)
    }
    
    func distanceTo(_ point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return sqrt(dx * dx + dy * dy)
    }
}

extension CGPoint: VectorArithmetic {

    public mutating func scale(by rhs: Double) {
        x = x * CGFloat(rhs)
        y = y * CGFloat(rhs)
    }
    
    public var magnitudeSquared: Double {
        return x * x + y * y
    }
    
    public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    public static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}
