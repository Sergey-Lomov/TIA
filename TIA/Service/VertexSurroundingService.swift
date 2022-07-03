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
        self.max = max >= min ? max : max + .dpi
    }
}

struct VertexSurrounding {
    let slots: [CGPoint]
    let edgesOuts: [(CGFloat, CGFloat)]
    let edgeSpacings: [Sector]
    let freeSectors: [Sector]
}

final class VertexSurroundingService {

    private let accuracy: CGFloat = 2

    var size: CGSize

    init(screenSize size: CGSize) {
        self.size = size
    }

    func surroundingFor(_ vertex: Vertex, layer: AdventureLayer, slotsCount: Int) -> VertexSurrounding {

        let center = vertex.point.scaled(size)
        let vertexRadius = Layout.Vertex.diameter / 2 * size.minSize
        let resourceSize = LayoutService.inventoryResourceSize(size).maxSize
        let resourcesOuterRadius = vertexRadius * (1 + Layout.Resources.Player.vertexGap) + resourceSize

        let edges = layer.edges(of: vertex)
        let edgesOuts = edgesOuts(edges: edges, center: center, innerRadius: vertexRadius, outerRadius: resourcesOuterRadius)
        let edgesSpacings = edgeSpacings(edgesOuts: edgesOuts, radius: vertexRadius)
        let freeSectors = freeSectors(edgesSpacings: edgesSpacings)
        let slots = slots(center: center, sectors: freeSectors, count: slotsCount, vertexRadius: vertexRadius)

        return VertexSurrounding(slots: slots, edgesOuts: edgesOuts, edgeSpacings: edgesSpacings, freeSectors: freeSectors)
    }

    // Inner radius is vertex radius
    // Outer radius is radius of resources edge
    private func edgesOuts(edges: [Edge], center: CGPoint, innerRadius: CGFloat, outerRadius: CGFloat) -> [(CGFloat, CGFloat)] {
        let edgesOutPoints: [(CGPoint, CGPoint)] = edges.map {
            let scaled = $0.curve.scaled(size)
            let inner = scaled.intersectionWith(center: center, radius: innerRadius, accuracy: accuracy)
            let outer = scaled.intersectionWith(center: center, radius: outerRadius, accuracy: accuracy)
            return (inner, outer)
        }

        return edgesOutPoints.map {
            let a1 = Math.angle(p1: $0.0, p2: center)
            let a2 = Math.angle(p1: $0.1, p2: center)
            return (a1, a2)
        }
    }

    private func edgeSpacings(edgesOuts: [(CGFloat, CGFloat)], radius: CGFloat) -> [Sector] {
        return edgesOuts.map {
            let deltaAngle = Layout.Edge.outSpacing / 2 / radius
            let mina = min($0.0, $0.1)
            let maxa = max($0.0, $0.1)
            return Sector(min: mina - deltaAngle, max: maxa + deltaAngle)
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
            let min = lastSpacing.max - .dpi
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
                cursor -= cursorStep
            }

            if slots.count >= count { break }
        }

        return slots
    }
}
