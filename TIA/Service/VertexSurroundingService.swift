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
    let edgesOuts: [Edge: [CGFloat]]
    let edgesSectors: [Edge: [Sector]]
    let freeSectors: [Int: [Sector]]
}

final class VertexSurroundingService {

    private let radiusesCount: Int = 3

    var size: CGSize

    init(screenSize size: CGSize) {
        self.size = size
    }

    func surroundingFor(_ vertex: Vertex, layer: AdventureLayer) -> VertexSurrounding {
        let cached: VertexSurrounding? = CacheService.shared.cached(id: .surrounding(vertex, layer))
        if let cached = cached { return cached }

        let center = vertex.point.scaled(size)
        let edges = layer.edges(of: vertex)
        let radiuses = radiuses()

        let edgesOuts = edgesOuts(edges: edges, center: center)
        let edgesSectors = edgesSectors(edgesOuts: edgesOuts, radiuses: radiuses)
        let freeSectors = freeSectors(edgesSectors)
        let slots = slots(center: center, sectors: freeSectors, radiuses: radiuses)

        let surrounding = VertexSurrounding(slots: slots, edgesOuts: edgesOuts, edgesSectors: edgesSectors, freeSectors: freeSectors)
        CacheService.shared.cach(id: .surrounding(vertex, layer), value: surrounding)
        return surrounding
    }

    private func radiuses() -> [CGFloat] {
        let vertexRadius = Layout.Vertex.diameter / 2 * size.minSize
        let resourceSize = LayoutService.inventoryResourceSize(size).maxSize
        return (0..<radiusesCount).map {
            let index = CGFloat($0)
            let resources = (index + 0.5) * resourceSize
            let gap = Layout.Resources.Player.vertexGap
            return vertexRadius + resources + gap
        }
    }

    private func edgesOuts(edges: [Edge], center: CGPoint) -> [Edge: [CGFloat]] {
        let vertexRadius = Layout.Vertex.diameter / 2 * size.minSize
        let resourceSize = LayoutService.inventoryResourceSize(size).maxSize
        let radiuses = (0...radiusesCount).map {
            vertexRadius + CGFloat($0) * resourceSize + Layout.Resources.Player.vertexGap
        }

        var result = [Edge: [CGFloat]]()
        edges.forEach() {
            let scaled = $0.curve.scaled(size)
            let intersectios = scaled.intersectionsWith(center: center, radiuses: radiuses)
            result[$0] = intersectios.map { Math.angle(p1: $0, p2: center) }
        }

        return result
    }

    private func edgesSectors(edgesOuts: [Edge: [CGFloat]], radiuses: [CGFloat]) -> [Edge: [Sector]] {
        var result = [Edge: [Sector]]()
        for edge in edgesOuts.keys {
            guard let outs = edgesOuts[edge] else { continue }
            result[edge] = []
            for i in 1..<outs.count {
                let deltaAngle = Layout.Edge.outSpacing / 2 / radiuses[i - 1]
                let min = min(outs[i], outs[i - 1])
                let max = max(outs[i], outs[i - 1])
                let sector = Sector(min: min - deltaAngle, max: max + deltaAngle)
                result[edge]?.append(sector)
            }
        }

        return result
    }

    private func freeSectors(_ edgesSectors: [Edge: [Sector]]) -> [Int: [Sector]] {
        var result = [Int: [Sector]]()
        for i in 0..<radiusesCount {
            let radiusEdgesSectors = edgesSectors.values.map { $0[i] }
            result[i] = radiusFreeSectors(radiusEdgesSectors)
        }
        return result
    }

    private func radiusFreeSectors(_ edgesSectors: [Sector]) -> [Sector] {
        guard !edgesSectors.isEmpty else {
            return [.init(min: 0, max: .dpi)]
        }

        let sorted = edgesSectors.sorted { $0.min < $1.min }
        var freeSectors = [Sector]()
        for index in 1..<sorted.count {
            let current = sorted[index]
            let prev = sorted[index - 1]
            if prev.max < current.min {
                let sector = Sector(min: prev.max, max: current.min)
                freeSectors.append(sector)
            }
        }
        if let last = sorted.last, let first = sorted.first {
            let min = last.max - .dpi
            if min < first.min {
                let sector = Sector(min: min, max: first.min)
                freeSectors.append(sector)
            }
        }

        return freeSectors
    }

    private func slots(center: CGPoint, sectors: [Int: [Sector]], radiuses: [CGFloat]) -> [CGPoint]
    {
        var result = [CGPoint]()
        for i in 0..<radiuses.count {
            guard let sectors = sectors[i] else { continue }
            let slots = radiusSlots(center: center, sectors: sectors, radius: radiuses[i])
            result.append(contentsOf: slots)
        }
        return result
    }

    private func radiusSlots(center: CGPoint, sectors: [Sector], radius: CGFloat) -> [CGPoint] {
        let sortedSectors = sectors.sorted {$0.size > $1.size}
        let resourceRadius = LayoutService.inventoryResourceSize(size).maxSize / 2
        let interitem = resourceRadius * 2 * Layout.Resources.Player.interitemGap

        var slots: [CGPoint] = []
        for sector in sortedSectors {
            let slotAngle = resourceRadius * 2 / radius
            var cursor = sector.max - slotAngle / 2
            let cursorStep = slotAngle + interitem / radius
            while cursor - slotAngle / 2 >= sector.min {
                let slot = CGPoint(center: .zero, angle: cursor, radius: radius)
                slots.append(slot)
                cursor -= cursorStep
            }
        }

        return slots
    }
}
