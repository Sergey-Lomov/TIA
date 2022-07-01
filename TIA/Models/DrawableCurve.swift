//
//  DrawableCurve.swift
//  TIA
//
//  Created by serhii.lomov on 14.06.2022.
//

import Foundation
import CoreGraphics

struct DrawableCurve {
    let id = UUID().uuidString
    var curve: BezierCurve
    let startAt: CGFloat
    let finishAt: CGFloat
    let widthMult: CGFloat

    init(curve: BezierCurve, startAt: CGFloat, finishAt: CGFloat, widthMult: CGFloat = 1) {
        self.curve = curve
        self.startAt = startAt
        self.finishAt = finishAt
        self.widthMult = widthMult
    }

    func scaled(_ scale: CGFloat) -> DrawableCurve {
        DrawableCurve(curve: curve.scaled(scale), startAt: startAt, finishAt: finishAt, widthMult: widthMult)
    }
}

extension Array where Element == DrawableCurve {
    func scaled(_ scale: CGFloat) -> [Element] {
        map { $0.scaled(scale) }
    }
}
