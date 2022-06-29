//
//  VertexActionsIconsService.swift
//  TIA
//
//  Created by serhii.lomov on 11.06.2022.
//

import Foundation
import CoreGraphics
import SwiftUI

class VertexActionsIconsService {
    private enum Elements {
        static let restart: [DrawableCurve] = {
            let compactisation = 0.8
            let spacerSize = 0.3 * .pi
            let arrowSize = 0.4 // If this will be changed, visual multiplier should also be changed
            let visualMult = 0.4 // Compensation for visual effect at arrow and curve connection
            let arrowAngle = 0.5 * .pi
            let bodyEndAngle = .pi - spacerSize / 2
            
            let body1 = BezierCurve.arc(from: -1 * bodyEndAngle, to: 0)
            let body2 = BezierCurve.arc(from: 0, to: bodyEndAngle)
            let bodyEnd = CGPoint(center: .zero, angle: bodyEndAngle)
            
            let leftAngle = bodyEndAngle - .hpi + arrowAngle * visualMult
            let leftEnd = CGPoint(center: bodyEnd, angle: leftAngle, radius: arrowSize)
            let leftArrow = BezierCurve.line(from: bodyEnd, to: leftEnd)
            
            let rightAngle = bodyEndAngle - .hpi - arrowAngle * (1 - visualMult)
            let rightEnd = CGPoint(center: bodyEnd, angle: rightAngle, radius: arrowSize)
            let rightArrow = BezierCurve.line(from: bodyEnd, to: rightEnd)
            
            return [
                .init(curve: body1, startAt: 0, finishAt: 0.35),
                .init(curve: body2, startAt: 0.35, finishAt: 0.7),
                .init(curve: leftArrow, startAt: 0.7, finishAt: 1),
                .init(curve: rightArrow, startAt: 0.7, finishAt: 1),
            ].scaled(0.5 * compactisation)
        }()
        
        static let exit: [DrawableCurve] = {
            let c1 = BezierCurve.arc(from: .pi * 0.5, to: .pi * 1.5).reversed()
            let c2 = BezierCurve.arc(from: .pi * -0.5, to: .pi * 0.5).reversed()
            let c3 = c1.scaled(0.5).translated(x: 0, y: 0.5)
            let c4 = c2.scaled(0.5).translated(x: 0, y: -0.5).reversed()
            let p1 = BezierCurve.onePoint(CGPoint(x: -0, y: -0.5))
            let p2 = BezierCurve.onePoint(CGPoint(x: 0, y: 0.5))
            return [
                .init(curve: c1, startAt: 0, finishAt: 0.25),
                .init(curve: c2, startAt: 0.25, finishAt: 0.5),
                .init(curve: c3, startAt: 0.5, finishAt: 0.65),
                .init(curve: c4, startAt: 0.65, finishAt: 0.8),
                .init(curve: p1, startAt: 0.9, finishAt: 0.9, widthMult: 2),
                .init(curve: p2, startAt: 1.0, finishAt: 1.0, widthMult: 2),
                ].scaled(0.5)
        }()
        
        static let finish: [DrawableCurve] = {
            let c1 = BezierCurve.arc(from: .pi * 0.5, to: .pi * 1.5, radius: 0.6).reversed()
            let c2 = BezierCurve.arc(from: .pi * -0.5, to: .pi * 0.5, radius: 0.6).reversed()
            
            func ray(_ angle: CGFloat) -> BezierCurve {
                let p1 = CGPoint(center: .zero, angle: angle, radius: 0.6)
                let p2 = CGPoint(center: .zero, angle: angle, radius: 1)
                return .line(from: p1, to: p2)
            }
            
            let raysCount = 7
            var rays: [DrawableCurve] = []
            for i in 0..<raysCount {
                let angle = -1 * CGFloat(i) * CGFloat.dpi / CGFloat(raysCount) - .hpi
                let start = 1.0 / CGFloat(raysCount) * CGFloat(i)
                let finish = 1.0 / CGFloat(raysCount) * CGFloat(i + 1)
                rays.append(.init(curve: ray(angle), startAt: start, finishAt: 1, widthMult: 0.5))
            }
            
            let curveTime = 1.0 - 1.0 / CGFloat(raysCount)
            var result: [DrawableCurve] = [
                .init(curve: c1, startAt: 0, finishAt: curveTime / 2, widthMult: 0.5),
                .init(curve: c2, startAt: curveTime / 2, finishAt: curveTime, widthMult: 0.5)
            ]
            result.append(contentsOf: rays)
            return result.scaled(0.5)
        }()
    }
    
    static func elements(_ item: VertexAction) -> [DrawableCurve]? {
        switch item {
        case .exit:
            return Elements.exit
        case .restart:
            return Elements.restart
        case .completeAdventure:
            return Elements.finish
        }
    }
}
