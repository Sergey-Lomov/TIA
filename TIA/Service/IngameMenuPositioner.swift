//
//  IngameMenuPositioner.swift
//  TIA
//
//  Created by serhii.lomov on 21.05.2022.
//

import Foundation
import CoreGraphics

final class IngameMenuPositioner {
    
    private static let degaultFragmentation = floor(1 / Layout.Vertex.diameter)
    private static let degaultTopRandomization: Int = 8
    
    let theme: AdventureTheme
    var points: [CGPoint] = []
    
    init(adventure: Adventure, size: CGSize, fragmentation: CGFloat = degaultFragmentation) {
        theme = adventure.theme
        updatePoints(adventure: adventure, size: size, fragmentation: fragmentation)
    }
    
    func getMenuVertexPoint() -> CGPoint {
        switch theme {
        case .dark, .truth:
            return getRandomTopPoint()
        case .light:
            return getBestPoint()
        }
    }
    
    private func getBestPoint() -> CGPoint {
        return points.first ?? .zero
    }
    
    private func getRandomTopPoint(randomization: Int = degaultTopRandomization) -> CGPoint {
        guard points.count > 0 else { return .zero }
        let maxIndex = min(points.count, randomization) - 1
        let index = Int.random(in: 0...maxIndex)
        return points[index]
    }
    
    func updatePoints(adventure: Adventure, size: CGSize, fragmentation: CGFloat = degaultFragmentation) {
        for x in 1..<Int(fragmentation) {
            for y in 1..<Int(fragmentation) {
                let point = CGPoint(x: x, y: y).scaled(1 / fragmentation).translated(x: -0.5, y: -0.5)
                points.append(point)
            }
        }
        
        let vertices = adventure.vertices.map { $0.point.scaled(size) }
        points.sort {
            let md0 = minDistance(point: $0.scaled(size), points: vertices)
            let md1 = minDistance(point: $1.scaled(size), points: vertices)
            return md0 > md1
        }
    }
    
    func randomMenuCurve(from: CGPoint, to: CGPoint) -> BezierCurve {
        switch theme {
        case .dark, .truth:
            let distance = from.distanceTo(to)
            let radiusRange = FloatRange(from: distance / 4, to: distance / 2)
            let angleRangle = FloatRange(from: .hpi / 4, to: .hpi / 2)
            return Math.randomCurve(from: from, to: to, controlRadius: radiusRange, controlAngle: angleRangle)
        case .light:
            return BezierCurve(points: [from, from, to, to])
        }
    }
    
    private func minDistance(point: CGPoint, points: [CGPoint]) -> CGFloat {
        let distances = points.map { $0.distanceTo(point) }
        return distances.min() ?? 0
    }
}
