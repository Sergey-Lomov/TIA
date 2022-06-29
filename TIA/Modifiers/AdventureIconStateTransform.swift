//
//  AdventureIconStateTransform.swift
//  TIA
//
//  Created by serhii.lomov on 29.06.2022.
//

import SwiftUI

struct AdventureIconStateTransform {
    var size: CGFloat
    var angle: CGFloat
    var offset: CGPoint
}

extension AdventureIconStateTransform: VectorArithmetic {

    static var zero = AdventureIconStateTransform(size: .zero, angle: .zero, offset: .zero)
    
    mutating func scale(by rhs: Double) {
        size.scale(by: rhs)
        angle.scale(by: rhs)
        offset.scale(by: rhs)
    }
    
    var magnitudeSquared: Double {
        size.magnitudeSquared * size.magnitudeSquared + angle.magnitudeSquared * angle.magnitudeSquared + offset.magnitudeSquared * offset.magnitudeSquared
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
        .init(size: lhs.size + rhs.size,
              angle: lhs.angle + rhs.angle,
              offset: lhs.offset + rhs.offset)
    }
    
    static func - (lhs: Self, rhs: Self) -> Self {
        .init(size: lhs.size - rhs.size,
              angle: lhs.angle - rhs.angle,
              offset: lhs.offset - rhs.offset)
    }
}
