//
//  ResourcePath.swift
//  TIA
//
//  Created by Serhii.Lomov on 25.04.2022.
//

import Foundation
import SwiftUI

extension Path {
    static func polygon(points: [CGPoint]) -> Path {
        var path = Path()
        guard let first = points.first else { return path }

        path.move(to: first)
        for i in 1...(points.count - 1) {
            path.addLine(to: points[i])
        }

        path.closeSubpath()
        return path
    }

    static func despair() -> Path {
        return polygon(points: [
            CGPoint(x: .cos90, y: .sin90),
            CGPoint(x: .cos210, y: .sin210),
            CGPoint(x: .cos330, y: .sin330)
        ])
    }

    static func anger() -> Path {
        return polygon(points: [
            CGPoint(x: .cos45, y: .sin45),
            CGPoint(x: .cos135, y: .sin135),
            CGPoint(x: .cos225, y: .sin225),
            CGPoint(x: .cos315, y: .sin315)
        ])
    }

    static func yearning() -> Path {
        return polygon(points: [
            CGPoint(x: .cos0, y: .sin0),
            CGPoint(x: .cos45 / 2, y: .sin45 / 2),
            CGPoint(x: .cos90, y: .sin90),
            CGPoint(x: .cos135 / 2, y: .sin135 / 2),
            CGPoint(x: .cos180, y: .sin180),
            CGPoint(x: .cos225 / 2, y: .sin225 / 2),
            CGPoint(x: .cos270, y: .sin270),
            CGPoint(x: .cos315 / 2, y: .sin315 / 2)
        ])
    }
}
