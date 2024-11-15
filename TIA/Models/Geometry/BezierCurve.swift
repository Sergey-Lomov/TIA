//
//  BezierCurve.swift
//  TIA
//
//  Created by Serhii.Lomov on 11.04.2022.
//

import CoreGraphics
import SwiftUI

enum ControlPoint {
    case p0
    case p1
    case p2
    case p3
}

struct BezierCurve {

    private static let intersectionSteps: Int = 1000
    private static let legthRatioLimit: Int = 100
    private static let tangentDelta: CGFloat = 0.01
    private static let lengthSteps: Int = 100

    let id = UUID().uuidString
    var p0: CGPoint
    var p1: CGPoint
    var p2: CGPoint
    var p3: CGPoint

    var points: [CGPoint] { [p0, p1, p2, p3] }
    var from: CGPoint { p0 }
    var to: CGPoint { p3 }
    var control1: CGPoint { p1 }
    var control2: CGPoint { p2 }

    static func onePoint(_ point: CGPoint) -> BezierCurve {
        return BezierCurve(points: [point, point, point, point])
    }

    static func line(from: CGPoint, to: CGPoint) -> BezierCurve {
        .init(points: [from, from, to, to])
    }

    static func arc(from: CGFloat, to: CGFloat, radius: CGFloat = 1) -> BezierCurve {
        let p0 = CGPoint(center: .zero, angle: from, radius: radius)
        let p3 = CGPoint(center: .zero, angle: to, radius: radius)
        let controlRadius = 4 / 3 * tan((to - from) / 4) * radius
        let p1 = CGPoint(center: p0, angle: from + .hpi, radius: controlRadius)
        let p2 = CGPoint(center: p3, angle: to - .hpi, radius: controlRadius)
        return .init(points: [p0, p1, p2, p3])
    }

    init(from: CGPoint, to: CGPoint, control1: CGPoint, control2: CGPoint) {
        self.init(points: [from, control1, control2, to])
    }

    init(points: [CGPoint]) {
        p0 = points[0]
        p1 = points[1]
        p2 = points[2]
        p3 = points[3]
    }

    func point(_ point: ControlPoint) -> CGPoint {
        switch point {
        case .p0: return p0
        case .p1: return p1
        case .p2: return p2
        case .p3: return p3
        }
    }

    mutating func setPoint(_ point: ControlPoint, newValue: CGPoint) {
        switch point {
        case .p0: p0 = newValue
        case .p1: p1 = newValue
        case .p2: p2 = newValue
        case .p3: p3 = newValue
        }
    }

    func length(stepsCount: Int = Self.lengthSteps) -> CGFloat {
        var result: CGFloat = 0
        var prevPoint = from

        for step in 1...stepsCount {
            let t = CGFloat(step) / CGFloat(stepsCount)
            let point = CGPoint(x: getX(t: t), y: getY(t: t))
            result += point.distanceTo(prevPoint)
            prevPoint = point
        }

        return result
    }

    func scaled(_ geometry: GeometryProxy) -> BezierCurve {
        return scaled(geometry.size)
    }

    func scaled(_ size: CGSize) -> BezierCurve {
        return scaled(x: size.width, y: size.height)
    }

    func scaled(_ scale: CGFloat) -> BezierCurve {
        return self.scaled(x: scale, y: scale)
    }

    func scaled(x xScale: CGFloat, y yScale: CGFloat) -> BezierCurve {
        let points = self.points.map {
            $0.scaled(x: xScale, y: yScale)
        }
        return BezierCurve(points: points)
    }

    func translated(x dx: CGFloat, y dy: CGFloat) -> BezierCurve {
        let points = self.points.map {
            $0.translated(x: dx, y: dy)
        }
        return BezierCurve(points: points)
    }

    func reversed() -> BezierCurve {
        return BezierCurve(points: [p3, p2, p1, p0])
    }

    func mirrored() -> BezierCurve {
        guard self != .zero else { return .zero }
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

    func getPoint(t: CGFloat) -> CGPoint {
        return CGPoint(x: getX(t: t), y: getY(t: t))
    }

    func getTangentAngle(t: CGFloat) -> CGFloat {
        let p1 = getPoint(t: t - Self.tangentDelta)
        let p2 = getPoint(t: t + Self.tangentDelta)
        return Math.angle(p1: p1, p2: p2)
    }

    func getNormalAngle(t: CGFloat) -> CGFloat {
        return getTangentAngle(t: t) + .hpi
    }

    func getT(lengthRatio: CGFloat, steps: Int = legthRatioLimit) -> CGFloat {
        let total = length(stepsCount: steps)
        let required = total * lengthRatio

        var current: CGFloat = 0
        var t: CGFloat = 0
        var point = getPoint(t: t)

        for _ in 0 ..< steps {
            let newT = t + 1 / CGFloat(steps)
            let newPoint = getPoint(t: newT)
            let newLenght = current + point.distanceTo(newPoint)

            if newLenght > required {
                let oldAccuracy = abs(current - required)
                let newAccuracy = abs(newLenght - required)
                return oldAccuracy < newAccuracy ? t : newT
            }

            point = newPoint
            t = newT
            current = newLenght
        }

        return t
    }

    func intersectionsTWith(center: CGPoint, radiuses: [CGFloat], steps: Int = intersectionSteps) -> [CGFloat] {
        return Math.stepSearch(from: 0, to: 1, steps: steps) { value in
            radiuses.map { radius in
                abs(getPoint(t: value).distanceTo(center) - radius)
            }
        }
    }

    func intersectionsWith(center: CGPoint, radiuses: [CGFloat], limit: Int = intersectionSteps) -> [CGPoint] {
        let ts = intersectionsTWith(center: center, radiuses: radiuses)
        return ts.map { getPoint(t: $0) }
    }

    func intersectionTWith(center: CGPoint, radius: CGFloat, steps: Int = intersectionSteps) -> CGFloat {
        let intersections = Math.stepSearch(from: 0, to: 1, steps: steps) {
            [abs(getPoint(t: $0).distanceTo(center) - radius)]
        }
        return intersections.first ?? .zero
    }

    func intersectionWith(center: CGPoint, radius: CGFloat, limit: Int = intersectionSteps) -> CGPoint {
        let t = intersectionTWith(center: center, radius: radius)
        return getPoint(t: t)
    }

    func frame() -> CGRect {
        return Path(curve: self).boundingRect
    }
}

extension BezierCurve: VectorArithmetic {

    static var zero: BezierCurve {
        BezierCurve(points: [CGPoint](repeating: .zero, count: 4))
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.p0 == rhs.p0 && lhs.p1 == rhs.p1 && lhs.p2 == rhs.p2 && lhs.p3 == rhs.p3
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
            lhs.p3 + rhs.p3
        ])
    }

    static func - (lhs: BezierCurve, rhs: BezierCurve) -> BezierCurve {
        return BezierCurve(points: [
            lhs.p0 - rhs.p0,
            lhs.p1 - rhs.p1,
            lhs.p2 - rhs.p2,
            lhs.p3 - rhs.p3
        ])
    }
}

// MARK: Timing curves
extension BezierCurve {

    static var linearTiming: BezierCurve {
        BezierCurve(points: [.zero, .zero, CGPoint(x: 1, y: 1), CGPoint(x: 1, y: 1)])
    }
}
