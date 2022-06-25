//
//  CGSize.swift
//  TIA
//
//  Created by Serhii.Lomov on 18.04.2022.
//

import Foundation
import SwiftUI

extension CGSize {
    
    var minSize: CGFloat { min(width, height) }
    var maxSize: CGFloat { max(width, height) }
    /// Ratio width to height
    var ratio: CGFloat { width / height }
    var half: CGSize { scaled(0.5) }
    
    init(_ size: CGFloat) {
        self.init(width: size, height: size)
    }
    
    func scaled(_ mult: CGFloat) -> CGSize {
        return CGSize(width: width * mult,
                      height: height * mult)
    }
}

extension CGSize: VectorArithmetic {
    public mutating func scale(by rhs: Double) {
        width *= rhs
        height *= rhs
    }

    public var magnitudeSquared: Double {
        width * width + height * height
    }
    
    public static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    public static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    
}
