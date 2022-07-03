//
//  Math.swift
//  TIA
//
//  Created by serhii.lomov on 02.05.2022.
//

import Foundation
import SwiftUI

final class Math {
    static let cirleControlCoefficient: CGFloat = 0.66666

    static func divide(_ v1: CGFloat, _ v2: CGFloat) -> CGFloat {
        return v2 == 0 ? 0 : v1 / v2
    }

    static func angle(p1: CGPoint, p2: CGPoint) -> CGFloat {
        let distance = sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2))
        let relative = p1.relative(zero: p2, unit: distance)
        let acos = acos(relative.x)
        return relative.y > 0 ? .dpi - acos : acos
    }

    static func dichotomize<Value>(border1: Value, border2: Value, accuracy: CGFloat, stepsLimit: Int, estimator: (Value) -> CGFloat ) -> Value? where Value: VectorArithmetic {

        var b1 = border1
        var b2 = border2

        for _ in 0 ..< stepsLimit {
            let accuracy1 = estimator(b1)
            let accuracy2 = estimator(b2)
            let mid = b1.average(with: b2)
            let midAccuracy = estimator(mid)
            if midAccuracy <= accuracy { return mid }
            if accuracy1 < accuracy2 { b2 = mid } else { b1 = mid }
        }

        return nil
    }

    static func stepSearch<Value>(from: Value, to: Value, steps: Int, estimator: (Value) -> [CGFloat]) -> [Value] where Value: VectorArithmetic {
        var bestAccuracy = estimator(from)
        let valuesCount = bestAccuracy.count
        var best = [Value](repeating: from, count: valuesCount)
        var step = from + to
        step.scale(by: 1 / Double(steps))
        var cursor = from

        for _ in 0 ..< steps {
            cursor += step
            let accuracies = estimator(cursor)
            for i in 0..<valuesCount {
                let accuracy = accuracies.safe(index: i)
                guard let accuracy = accuracy else {
                    fatalError("Etimator returns array of invalid size")
                }

                if accuracy < bestAccuracy[i] {
                    best[i] = cursor
                    bestAccuracy[i] = accuracy
                }
            }
        }

        return best
    }

    static func randomCurve(from: CGPoint, to: CGPoint, controlRadius: ClosedRange<CGFloat>, controlAngle: ClosedRange<CGFloat>) -> BezierCurve {
        let fromToAngle = Math.angle(p1: to, p2: from)
        let toFromAngle = fromToAngle + .pi
        let c1_mult: CGFloat = Bool.random() ? 1 : -1
        let c2_mult: CGFloat  = Bool.random() ? 1 : -1
        let c1_angle = fromToAngle + CGFloat.random(in: controlAngle) * c1_mult
        let c2_angle = toFromAngle + CGFloat.random(in: controlAngle) * c2_mult
        let c1_radius = CGFloat.random(in: controlRadius)
        let c2_radius = CGFloat.random(in: controlRadius)
        let c1 = CGPoint(center: from, angle: c1_angle, radius: c1_radius)
        let c2 = CGPoint(center: to, angle: c2_angle, radius: c2_radius)
        return BezierCurve(points: [from, c1, c2, to])
    }

    /// Ratio should be width to height
    static func rectSize(ratio: CGFloat, circumscribedRadius: CGFloat) -> CGSize {
        let width = 2 * ratio / sqrt(1 + ratio * ratio) * circumscribedRadius
        let height = 2 / sqrt(1 + ratio * ratio) * circumscribedRadius
        return CGSize(width: width, height: height)
    }
}

extension VectorArithmetic {
    func average(with: Self) -> Self {
        var result = self + with
        result.scale(by: 0.5)
        return result
    }
}
