//
//  BezierCurve.swift
//  TIA
//
//  Created by Serhii.Lomov on 11.04.2022.
//

import CoreGraphics
import SwiftUI

struct BezierCurve: Equatable {
    
    var p0: CGPoint
    var p1: CGPoint
    var p2: CGPoint
    var p3: CGPoint
    
    var points: [CGPoint] { [p0, p1, p2, p3] }
    var from: CGPoint { p0 }
    var to: CGPoint { p3 }
    var control1: CGPoint { p1 }
    var control2: CGPoint { p2 }
    
    func length(stepsCount: Int) -> CGFloat {
        var lenght: CGFloat = 0
        var prevPoint = from
        
        for step in 1...stepsCount {
            let t = CGFloat(step) / CGFloat(stepsCount)
            let point = CGPoint(x: getX(t: t), y: getY(t: t))
            lenght = lenght + point.distanceTo(prevPoint)
            prevPoint = point
        }
        
        return lenght
    }
    
    init(from: CGPoint, to: CGPoint, control1: CGPoint, control2: CGPoint) {
        self.init(points: [from, control1, control2, to])
    }
    
    init(points:[CGPoint]) {
        p0 = points[0]
        p1 = points[1]
        p2 = points[2]
        p3 = points[3]
    }
    
    func multedCurve(x xScale: CGFloat, y yScale: CGFloat) -> BezierCurve {
        let points = self.points.map {
            $0.multedPoint(x: xScale, y: yScale)
        }
        return BezierCurve(points: points)
    }
    
    func translatedCurve(x dx: CGFloat, y dy: CGFloat) -> BezierCurve {
        let points = self.points.map {
            $0.translatedPoint(x: dx, y: dy)
        }
        return BezierCurve(points: points)
    }
    
    func selfMirroredCurve() -> BezierCurve {
        let p1m = p1.mirroredByLine(p1: p0, p2: p3)
        let p2m = p2.mirroredByLine(p1: p0, p2: p3)
        return BezierCurve(points: [p0, p1m, p2m, p3])
    }
    
    func randomControlsCurve(maxDelta: CGFloat) -> BezierCurve {
        let p1r = p1.randomPoint(maxDelta: maxDelta)
        let p2r = p2.randomPoint(maxDelta: maxDelta)
        return BezierCurve(points: [p0, p1r, p2r, p3])
    }
    
    private func getCoord(t: CGFloat, p0: CGFloat, p1: CGFloat, p2: CGFloat, p3: CGFloat) -> CGFloat {
        let c1 = pow(1 - t, 3) * p0
        let c2 = 3 * pow(1 - t, 2) * t * p1
        let c3 = 3 * (1 - t) * pow(t, 2) * p2
        let c4 = pow(t, 3) * p3
        return c1 + c2 + c3 + c4
    }
    
    func getX(t: CGFloat) -> CGFloat {
        return getCoord(t: t, p0: p0.x, p1: p1.x, p2: p2.x, p3: p3.x)
    }
    
    func getY(t: CGFloat) -> CGFloat {
        return getCoord(t: t, p0: p0.y, p1: p1.y, p2: p2.y, p3: p3.y)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.p0 == rhs.p0 && lhs.p1 == rhs.p1 && lhs.p2 == rhs.p2 && lhs.p3 == rhs.p3
    }
}

extension BezierCurve: VectorArithmetic {
    
    static var zero: BezierCurve {
        BezierCurve(points: [CGPoint](repeating: .zero, count: 4))
    }
    
    mutating func scale(by rhs: Double) {
        p0.scale(by: rhs)
        p1.scale(by: rhs)
        p2.scale(by: rhs)
        p3.scale(by: rhs)
    }
    
    var magnitudeSquared: Double {
        return p0.magnitudeSquared * p0.magnitudeSquared
        + p1.magnitudeSquared * p1.magnitudeSquared
        + p2.magnitudeSquared * p2.magnitudeSquared
        + p3.magnitudeSquared * p3.magnitudeSquared
    }
    
    static func + (lhs: BezierCurve, rhs: BezierCurve) -> BezierCurve {
        return BezierCurve(points: [
            lhs.p0 + rhs.p0,
            lhs.p1 + rhs.p1,
            lhs.p2 + rhs.p2,
            lhs.p3 + rhs.p3,
        ])
    }
    
    static func - (lhs: BezierCurve, rhs: BezierCurve) -> BezierCurve {
        return BezierCurve(points: [
            lhs.p0 - rhs.p0,
            lhs.p1 - rhs.p1,
            lhs.p2 - rhs.p2,
            lhs.p3 - rhs.p3,
        ])
    }
}
