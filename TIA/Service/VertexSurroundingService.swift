//
//  VertexSurroundingService.swift
//  TIA
//
//  Created by serhii.lomov on 30.04.2022.
//

import Foundation
import CoreGraphics

struct Sector {
    let min: CGFloat
    let max: CGFloat
    
    var size: CGFloat { max - min }
    
    func length(radius: CGFloat) -> CGFloat {
        (max - min) * radius
    }
    
    init(min: CGFloat, max: CGFloat) {
        self.min = min
        self.max = max >= min ? max : max + .pi * 2
    }
}

struct VertexSurrounding {
    let slots: [CGPoint]
    let edgesOuts: [CGFloat]
    let edgeSpacings: [Sector]
    let freeSectors: [Sector]
}

final class VertexSurroundingService {
    
    private let accuracy: CGFloat = 2
    
    var size: CGSize
    
    init(screenSize size:CGSize) {
        self.size = size
    }

    func surroundingFor(_ vertex: Vertex, slotsCount: Int) -> VertexSurrounding {
        
        let center = vertex.point.scaled(size)
        let radius = Layout.Vertex.diameter / 2 * size.minSize
        
        let edgesOuts = edgesOuts(edges: vertex.edges, center: center, radius: radius)
        let edgesSpacings = edgeSpacings(edgesOuts: edgesOuts, radius: radius)
        let freeSectors = freeSectors(edgesSpacings: edgesSpacings)
        let slots = slots(center: center, sectors: freeSectors, count: slotsCount, vertexRadius: radius)
        
        return VertexSurrounding(slots: slots, edgesOuts: edgesOuts, edgeSpacings: edgesSpacings, freeSectors: freeSectors)
    }
    
    private func edgesOuts(edges: [Edge], center: CGPoint, radius: CGFloat) -> [CGFloat] {
        let edgesOutPoints: [CGPoint] = edges.map {
            let scaled = $0.curve.scaled(size)
            return scaled.intersectionWith(center: center, radius: radius, accuracy: accuracy)
        }
        
        return edgesOutPoints.map {
            let radius = sqrt(pow(center.x - $0.x, 2) + pow(center.y - $0.y, 2))
            let relative = $0.relative(zero: center, unit: radius)
            let acos = acos(relative.x)
            return relative.y > 0 ? .pi * 2 - acos : acos
        }
    }
    
    private func edgeSpacings(edgesOuts: [CGFloat], radius: CGFloat) -> [Sector] {
        return edgesOuts.map {
            let deltaAngle = Layout.Edge.outSpacing / 2 / radius
            return Sector(min: $0 - deltaAngle, max: $0 + deltaAngle)
        }.sorted { $0.min < $1.min }
    }
    
    private func freeSectors(edgesSpacings: [Sector]) -> [Sector] {
        guard !edgesSpacings.isEmpty else { return [] }
        
        var freeSectors: [Sector] = []
        for index in 1..<edgesSpacings.count {
            let current = edgesSpacings[index]
            let prev = edgesSpacings[index - 1]
            if prev.max < current.min {
                let sector = Sector(min: prev.max, max: current.min)
                freeSectors.append(sector)
            }
        }
        if let lastSpacing = edgesSpacings.last, let firstSpacing = edgesSpacings.first {
            let min = lastSpacing.max - 2 * .pi
            if min < firstSpacing.min {
                let sector = Sector(min: min, max: firstSpacing.min)
                freeSectors.append(sector)
            }
        }
        
        return freeSectors
    }
    
    private func slots(center: CGPoint, sectors: [Sector], count: Int, vertexRadius: CGFloat) -> [CGPoint] {
        let sortedSectors = sectors.sorted {$0.size > $1.size}
        let resourceRadius = vertexRadius * Layout.Resources.Player.sizeRatio
        let firstRadius = vertexRadius * (1 + Layout.Resources.Player.vertexGap) + resourceRadius
        let interitem = resourceRadius * 2 * Layout.Resources.Player.interitemGap
        
        var slots: [CGPoint] = []
        let radius = firstRadius
        for sector in sortedSectors {
            let slotAngle = resourceRadius * 2 / radius
            var cursor = sector.max - slotAngle / 2
            let cursorStep = slotAngle + interitem / radius
            while cursor - slotAngle / 2 >= sector.min {
                let slot = CGPoint(center: .zero, angle: cursor, radius: radius)
                slots.append(slot)
                if slots.count >= count { break }
                cursor = cursor - cursorStep
            }
            
            if slots.count >= count { break }
        }
        
        return slots
    }
}