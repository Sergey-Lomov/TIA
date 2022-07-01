//
//  CGFloat.swift
//  TIA
//
//  Created by Serhii.Lomov on 16.04.2022.
//

import CoreGraphics

extension CGFloat {
    static var unsingularZero: CGFloat = 0.0001 // Uses for CGAffinTransform related calculations to avoid "singular matrix" warning. Exists constant "leastNonzeroMagnitude" is not valid fix.
    static var negativeInfinity: CGFloat { -1 * infinity }
    static var hpi: CGFloat { .pi / 2 }
    static var dpi: CGFloat { .pi * 2 }

    static var cos0: CGFloat = 1
    static var sin0: CGFloat = 0
    static var cos30: CGFloat = sqrt(3) / 2
    static var sin30: CGFloat = 0.5
    static var cos45: CGFloat = sqrt(2) / 2
    static var sin45: CGFloat = sqrt(2) / 2
    static var cos90: CGFloat = 0
    static var sin90: CGFloat = 1
    static var cos135: CGFloat = sqrt(2) / -2
    static var sin135: CGFloat = sqrt(2) / 2
    static var cos180: CGFloat = -1
    static var sin180: CGFloat = 0
    static var cos210: CGFloat = sqrt(3) / -2
    static var sin210: CGFloat = -0.5
    static var cos225: CGFloat = sqrt(2) / -2
    static var sin225: CGFloat = sqrt(2) / -2
    static var cos270: CGFloat = 0
    static var sin270: CGFloat = -1
    static var cos315: CGFloat = sqrt(2) / 2
    static var sin315: CGFloat = sqrt(2) / -2
    static var cos330: CGFloat = sqrt(3) / 2
    static var sin330: CGFloat = -0.5

    static func range(_ from: CGFloat, _ to: CGFloat) -> ClosedRange<CGFloat> {
        from...to
    }
}
