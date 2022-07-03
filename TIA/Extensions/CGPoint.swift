//
//  CGPoint.swift
//  TIA
//
//  Created by Serhii.Lomov on 10.04.2022.
//

import CoreGraphics
import SwiftUI

extension CGPoint {

    static func from(_ from: CGPoint, to: CGPoint, t: CGFloat) -> CGPoint {
        let x = from.x + (to.x - from.x) * t
        let y = from.y + (to.y - from.y) * t
        return CGPoint(x: x, y: y)
    }

    init(center: CGPoint = .zero, angle: CGFloat, radius: CGFloat = 1) {
        let x = center.x + cos(angle) * radius
        let y = center.y - sin(angle) * radius // Due to inveted Y axis
        self.init(x: x, y: y)
    }

    func mirrored(point: CGPoint = .zero) -> CGPoint {
         CGPoint(x: 2 * point.x - self.x, y: 2 * point.y - self.y)
    }

    func scaled(_ geometry: GeometryProxy) -> CGPoint {
        scaled(geometry.size)
    }

    func scaled(_ size: CGSize) -> CGPoint {
        scaled(x: size.width, y: size.height)
    }

    func scaled(_ scale: CGFloat) -> CGPoint {
        scaled(x: scale, y: scale)
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

    func translated(by size: CGSize) -> CGPoint {
        CGPoint(x: x + size.width, y: y + size.height)
    }

    func mirroredByLine(p1: CGPoint, p2: CGPoint) -> CGPoint {
        mirroredByLine(Line(p1: p1, p2: p2))
    }

    func relative(zero: CGPoint, unit: CGFloat = 1) -> CGPoint {
        CGPoint(x: (x - zero.x) / unit, y: (y - zero.y) / unit)
    }

    func randomPoint(maxDelta: CGFloat) -> CGPoint {
        let rx = CGFloat.random(in: (x - maxDelta)...(x + maxDelta))
        let ry = CGFloat.random(in: (y - maxDelta)...(y + maxDelta))
        return CGPoint(x: rx, y: ry)
    }

    func mirroredByLine(_ l: Line) -> CGPoint {
        switch l.type {
        case .common:
            let _c = y - l.b / l.a * x
            let xm = -1 * (l.c + l.b * _c) / (l.a + l.b * l.b / l.a)
            let ym = l.b / l.a * xm + _c
            let xr = 2 * xm - x
            let yr = 2 * ym - y
            return CGPoint(x: xr, y: yr)
        case .horizontal(let ly):
            let yr = 2 * ly - y
            return CGPoint(x: x, y: yr)
        case .vertical(let lx):
            let xr = 2 * lx - x
            return CGPoint(x: xr, y: y)
        }
    }

    func distanceTo(_ point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return sqrt(dx * dx + dy * dy)
    }

    func toUnit(geometry: GeometryProxy) -> UnitPoint {
        UnitPoint(x: (x / geometry.size.width) + 0.5,
                  y: (y / geometry.size.height) + 0.5)
    }
}

extension CGPoint: VectorArithmetic {

    public mutating func scale(by rhs: Double) {
        x *= CGFloat(rhs)
        y *= CGFloat(rhs)
    }

    public var magnitudeSquared: Double {
        x * x + y * y
    }

    public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
