//
//  Math.swift
//  TIA
//
//  Created by serhii.lomov on 02.05.2022.
//

import Foundation
import SwiftUI

final class Math {
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
    
    static func stepSearch<Value>(from: Value, to: Value, steps: Int, estimator: (Value) -> CGFloat) -> Value where Value: VectorArithmetic {
        var best = from
        var bestAccuracy = estimator(from)
        var step = from + to
        step.scale(by: 1 / Double(steps))
        var cursor = from
        
        for _ in 0 ..< steps {
            cursor += step
            let accuracy = estimator(cursor)
            if accuracy < bestAccuracy {
                best = cursor
                bestAccuracy = accuracy
            }
        }
        
        return best
    }
}

extension VectorArithmetic {
    func average(with: Self) -> Self {
        var result = self + with
        result.scale(by: 0.5)
        return result
    }
}
