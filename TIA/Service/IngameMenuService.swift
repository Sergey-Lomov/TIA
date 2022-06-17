//
//  IngameMenuService.swift
//  TIA
//
//  Created by serhii.lomov on 27.05.2022.
//

import Foundation
import CoreGraphics

enum IngameMenuItem: String {
    case exit
    case restart
    
    var onVisit: VertexAction? {
        switch self {
        case .exit:
            return .exit
        case .restart:
            return .restart
        }
    }
    
    var actions: [VertexAction] {
        return []
    }
}

final class IngameMenuService {
    private static let vertexIdPrefix = "menu_"
    private static let edgeIdPrefix = "edge_to_"
    
    static func menuLayer(from source: Vertex) -> AdventureLayer {
        let items = GameEngine.shared.availableIngameMenuItems()
        
        var vertices: [Vertex] = []
        var angle: CGFloat = 0
        let radius = Layout.Menu.radius
        for item in items {
            let point = CGPoint(center: source.point, angle: angle, radius: radius)
            let id = vertexIdPrefix + item.rawValue + UUID().uuidString
            let vertex = Vertex(id: id, state: .seed, point: point)
            vertex.actions = item.actions
            vertex.onVisit = item.onVisit
            vertices.append(vertex)
            
            angle += .dpi / CGFloat(items.count)
        }
        
        let radiusRange = FloatRange(from: radius / 4, to: radius / 2)
        let angleRange =  FloatRange(from: .hpi / 4, to: .hpi / 2)
        var edges: [Edge] = []
        for vertex in vertices {
            // TODO: For light theme shoudl be used straight edges
            let curve = Math.randomCurve(from: source.point, to: vertex.point, controlRadius: radiusRange, controlAngle: angleRange)
            let id = edgeIdPrefix + vertex.id
            let edge = Edge(id: id, from: source, to: vertex, growOnStart: true, curve: curve)
            edges.append(edge)
        }
        
        vertices.append(source)
        return AdventureLayer(type: .menu, state: .preparing, vertices: vertices, edges: edges, entrance: source)
    }
}
