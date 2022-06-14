//
//  ResourceStateTransform.swift
//  TIA
//
//  Created by serhii.lomov on 10.05.2022.
//

import Foundation
import CoreGraphics
import SwiftUI

struct ResourceStateTransform {
    var localOffset: CGPoint
    var localAngle: CGFloat
    var size: CGSize
    var positioning: CGFloat
}

extension ResourceStateTransform: VectorArithmetic {
    
    static var zero = ResourceStateTransform(localOffset: .zero, localAngle: .zero, size: .zero, positioning: .zero)
    
    mutating func scale(by rhs: Double) {
        localOffset.scale(by: rhs)
        localAngle.scale(by: rhs)
        size.scale(by: rhs)
        positioning.scale(by: rhs)
    }
    
    var magnitudeSquared: Double {
        localOffset.magnitudeSquared * localOffset.magnitudeSquared + localAngle.magnitudeSquared * localAngle.magnitudeSquared + size.magnitudeSquared * size.magnitudeSquared + positioning.magnitudeSquared * positioning.magnitudeSquared
    }
    
    static func + (lhs: ResourceStateTransform, rhs: ResourceStateTransform) -> ResourceStateTransform {
        .init(localOffset: lhs.localOffset + rhs.localOffset,
              localAngle: lhs.localAngle + rhs.localAngle,
              size: lhs.size + rhs.size,
              positioning: lhs.positioning + rhs.positioning)
    }
    
    static func - (lhs: ResourceStateTransform, rhs: ResourceStateTransform) -> ResourceStateTransform {
        .init(localOffset: lhs.localOffset - rhs.localOffset,
              localAngle: lhs.localAngle - rhs.localAngle,
              size: lhs.size - rhs.size,
              positioning: lhs.positioning - rhs.positioning)
    }
}