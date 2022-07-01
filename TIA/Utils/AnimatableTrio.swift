//
//  AnimatableTrio.swift
//  TIA
//
//  Created by serhii.lomov on 19.05.2022.
//

import Foundation
import SwiftUI

struct AnimatableTrio<T1: VectorArithmetic, T2: VectorArithmetic, T3: VectorArithmetic>: VectorArithmetic {
    var first: T1
    var second: T2
    var third: T3

    init(_ first: T1, _ second: T2, _ third: T3) {
        self.first = first
        self.second = second
        self.third = third
    }

    static func - (lhs: Self, rhs: Self) -> Self {
        return .init(lhs.first - rhs.first, lhs.second - rhs.second, lhs.third - rhs.third)
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        return .init(lhs.first + rhs.first, lhs.second + rhs.second, lhs.third + rhs.third)
    }

    mutating func scale(by rhs: Double) {
        first.scale(by: rhs)
        second.scale(by: rhs)
        third.scale(by: rhs)
    }

    var magnitudeSquared: Double {
        first.magnitudeSquared * first.magnitudeSquared + second.magnitudeSquared * second.magnitudeSquared + third.magnitudeSquared * third.magnitudeSquared
    }

    static var zero: Self {
        .init(.zero, .zero, .zero)
    }
}
