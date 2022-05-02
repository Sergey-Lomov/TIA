//
//  CGPoint.swift
//  TIA
//
//  Created by Serhii.Lomov on 10.04.2022.
//

import CoreGraphics
import SwiftUI

extension CGPoint {
    
    init(center: CGPoint, angle: CGFloat, radius: CGFloat) {
        let x = center.x + cos(angle) * radius
        let y = center.y - sin(angle) * radius // Due to inveted Y axis
        self.init(x: x, y: y)
    }
    
    func scaled(_ geometry: GeometryProxy) -> CGPoint {
        scaled(geometry.size)
    }
    
    func scaled(_ size: CGSize) -> CGPoint {
        return scaled(x: size.width, y: size.height)
    }
    
    func scaled(x sx: CGFloat, y sy: CGFloat) -> CGPoint {
        CGPoint(x: x * sx, y: y * sy)
    }
    
    func translated(x dx: CGFloat, y dy: CGFloat) -> CGPoint {
        CGPoint(x: x + dx, y: y + dy)
    }
    
    func translated(by point: CGPoint) -> CGPoint {
        CGPoint(x: x + point.x, y: y + point.y)
    }
    
    func mirroredByLine(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return mirroredByLine(Line(p1: p1, p2: p2))
    }
    
    func relative(zero: CGPoint, unit: CGFloat = 1) -> CGPoint {
        return CGPoint(x: (x - zero.x) / unit, y: (y - zero.y) / unit)
    }
    
    func randomPoint(maxDelta: CGFloat) -> CGPoint {
        let rx = CGFloat.random(in: (x - maxDelta)...(x + maxDelta))
        let ry = CGFloat.random(in: (y - maxDelta)...(y + maxDelta))
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
    
    func toUnit(geometry: GeometryProxy) -> UnitPoint {
        return UnitPoint(x: (x / geometry.size.width) + 0.5, y: (y / geometry.size.width) + 0.5)
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
