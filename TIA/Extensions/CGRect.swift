//
//  CGRect.swift
//  TIA
//
//  Created by serhii.lomov on 29.05.2022.
//

import Foundation
import CoreGraphics

extension CGRect {

    var center: CGPoint { CGPoint(x: midX, y: midY) }

    init(center: CGPoint, size: CGSize) {
        let origin = center.translated(by: size.scaled(-0.5))
        self.init(origin: origin, size: size)
    }

    func union(_ point: CGPoint) -> CGRect {
        union(CGRect(origin: point, size: .zero))
    }

    func nearestPoint(to: CGPoint) -> CGPoint {
        let x = min(maxX, max(minX, to.x))
        let y = min(maxY, max(minY, to.y))
        return CGPoint(x: x, y: y)
    }
}
