//
//  IngameMenuService.swift
//  TIA
//
//  Created by serhii.lomov on 27.05.2022.
//

import Foundation
import CoreGraphics
import Combine

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

    static func menuLayer(from source: Vertex, theme: AdventureTheme, items: [IngameMenuItem]) -> AdventureLayer {

        var vertices: [Vertex] = []
        var angle: CGFloat = 0
        let radius = Layout.Menu.radius
        for item in items {
            let point = CGPoint(center: source.point, angle: angle, radius: radius)
            let id = vertexIdPrefix + item.rawValue
            let vertex = Vertex(originId: id, state: .seed, point: point)
            vertex.actions = item.actions
            vertex.onVisit = item.onVisit
            vertices.append(vertex)

            angle += .dpi / CGFloat(items.count)
        }

        let radiusRange = FloatRange(from: radius / 4, to: radius / 2)
        let angleRange =  FloatRange(from: .hpi / 4, to: .hpi / 2)
        var edges: [Edge] = []
        for vertex in vertices {
            let curve = Math.randomCurve(from: source.point, to: vertex.point, controlRadius: radiusRange, controlAngle: angleRange)
            let line = BezierCurve.line(from: source.point, to: vertex.point)
            let edgeCurve = theme == .light ? line : curve
            let id = edgeIdPrefix + vertex.id
            let edge = Edge(originId: id, from: source, to: vertex, growOnStart: true, curve: edgeCurve, theme: theme)
            edges.append(edge)
        }

        vertices.append(source)
        return AdventureLayer(type: .menu, state: .preparing, vertices: vertices, edges: edges, entrance: source)
    }
}
