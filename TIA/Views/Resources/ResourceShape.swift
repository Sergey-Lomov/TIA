//
//  ResourceShape.swift
//  TIA
//
//  Created by Serhii.Lomov on 25.04.2022.
//

import Foundation
import SwiftUI

struct ResourceShape: InsettableShape {
    let type: ResourceType
    var inset: CGFloat = .zero

    func path(in rect: CGRect) -> Path {
        var size = rect.size.half
        size.width -= inset / 2
        size.height -= inset / 2
        var transform = CGAffineTransform(scaleX: size.width, y: size.height)
        transform = transform.translatedBy(x: 1, y: 1)

        switch type {
        case .despair:
            return Path.despair().applying(transform)
        case .anger:
            return Path.anger().applying(transform)
        case .yearning:
            return Path.yearning().applying(transform)
        case .inspiration:
            return Path()
        case .fun:
            return Path()
        case .love:
            return Path()
        }
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var shape = self
        shape.inset += amount
        return shape
    }
}
