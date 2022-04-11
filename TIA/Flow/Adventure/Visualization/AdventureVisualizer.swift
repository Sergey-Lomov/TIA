//
//  AdventureVisualizer.swift
//  TIA
//
//  Created by Serhii.Lomov on 12.04.2022.
//

import CoreGraphics

class AdventureVisualizer {
    private let totalRandomizationLimit = 1000
    
    var visualization: AdventureVisualization
    var minVertexDistance: CGFloat = 0.1
    var bestNeighborsDistance: CGFloat = 0.2
    
    private var vertices: [VertexVisualization] {
        visualization.vertices
    }
    
    private var edges: [EdgeVisualization] {
        visualization.edges
    }
    
    private var randomizationLimit: Int {
        let entitiesCount = visualization.model.vertices.count + visualization.model.edges.count
        return totalRandomizationLimit / entitiesCount
    }
    
    init(adventure: Adventure) {
        visualization = AdventureVisualization(model: adventure,
                                               vertices: [],
                                               edges: [])
    }
    
    func updateVisualization() {
        for vertex in visualization.model.vertices {
            let visualVertex = visualizeVertex(vertex)
            visualization.vertices.append(visualVertex)
        }
    }
    
    private func visualizeVertex(_ vertex: Vertex) -> VertexVisualization {
        
        let neighbors = visualizedNeighbors(vertex)
        
        var bestPosition = (point: CGPoint.zero,
                            weight: -1 * CGFloat.infinity)
        var acceptable = false
        var tries = 0
        while tries < randomizationLimit || !acceptable {
            let position = randomizePosition(vertex, neighbors: neighbors)
            guard let position = position else { continue }
            
            if position.weight > bestPosition.weight {
                bestPosition = position
                acceptable = true
            }
            
            tries = tries + 1
        }
        
        return VertexVisualization(model: vertex, position: bestPosition.point)
    }
    
    private func visualizedNeighbors(_ vertex: Vertex) -> [VertexVisualization] {
        let edges = edges.filter {
            $0.model.from.id == vertex.id || $0.model.to.id == vertex.id
        }
        let neighborsIds = Set(edges.flatMap {
            [$0.model.from.id, $0.model.to.id]
        })
        
        return neighborsIds.compactMap { id in
            vertices.first { v in v.model.id == id }
        }
    }
    
    private func randomizePosition(_ vertex: Vertex, neighbors: [VertexVisualization]) -> (point: CGPoint, weight: CGFloat)? {
        let point = CGPoint(x: CGFloat(arc4random()),
                            y: CGFloat(arc4random()))
        
        let criticalDistance = vertices.contains {
            $0.position.distanceTo(point) <= minVertexDistance
        }
        if criticalDistance { return nil }
        
        var weight = CGFloat.zero
        for neighbor in neighbors {
            let distance = neighbor.position.distanceTo(point)
            let gap = abs(distance - bestNeighborsDistance)
            weight = weight - gap
        }
        
        return (point: point, weight: weight)
    }
}
