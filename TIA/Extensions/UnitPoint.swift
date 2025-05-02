//
//  UnitPoint.swift
//  TIA
//
//  Created by serhii.lomov on 02.07.2022.
//

import Foundation
import SwiftUI

extension UnitPoint: @retroactive VectorArithmetic {

    public mutating func scale(by rhs: Double) {
        x *= rhs
        y *= rhs
    }

    public var magnitudeSquared: Double {
        x * x + y * y
    }

    public static func + (lhs: UnitPoint, rhs: UnitPoint) -> UnitPoint {
        UnitPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func - (lhs: UnitPoint, rhs: UnitPoint) -> UnitPoint {
        UnitPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}
