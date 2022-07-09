//
//  AdventureService.swift
//  TIA
//
//  Created by serhii.lomov on 05.07.2022.
//

import Foundation

final class AdventureService {

    static func adventureFor(_ prototype: AdventurePrototype, layout: AdventureLayout) -> Adventure {
        let layer = layerFor(prototype, layout: layout)
        return Adventure(id: prototype.id, index: prototype.index, theme: prototype.theme, initialLayer: layer, doneShape: prototype.doneShape)
    }

    static func layerFor(_ protoAdventure: AdventurePrototype, layout: AdventureLayout, forcedEntrance: Vertex? = nil) -> AdventureLayer {
        var protoAdventure = protoAdventure.copy()
        let protoEntrance = protoAdventure.vertices.first { $0.role == .entrance }
        guard let protoEntrance = protoEntrance else {
            fatalError("Layout have no entrance")
        }
        let protoEntrancePoint = layout.vertices[protoEntrance.id] ?? .zero
        let pointDelta = forcedEntrance?.point.translated(by: protoEntrancePoint.scaled(-1)) ?? .zero
        layout.translate(by: pointDelta)

        var vertices: [Vertex] = protoAdventure.vertices.compactMap {
            guard $0.role != .entrance else { return nil }
            let vertex = vertexFor($0, layout: layout)
            protoAdventure.updateVertexId($0.id, to: vertex.id)
            if $0.role == .exit { vertex.onVisit = .completeAdventure }
            return vertex
        }

        let defaultEntrance = vertexFor(protoEntrance, layout: layout)
        forcedEntrance?.mergeWith(defaultEntrance)
        let entrance = forcedEntrance ?? defaultEntrance
        vertices.append(entrance)
        protoAdventure.updateVertexId(protoEntrance.id, to: entrance.id)

        let edges: [Edge] = protoAdventure.edges.map {
            guard let from = vertices.firstById($0.from),
                  let to = vertices.firstById($0.to) else {
                fatalError("Missed vertex connected to edge \"\($0.id)\"")
            }

            let p1 = layout.edges[$0.id]?.p1 ?? from.point
            let p2 = layout.edges[$0.id]?.p2 ?? to.point
            let curve = BezierCurve(points: [from.point, p1, p2, to.point])
            let id = $0.id + UUID().uuidString
            let edge = Edge(id: id, from: from, to: to, price: $0.price, growOnStart: $0.growOnStart, curve: curve, theme: protoAdventure.theme)
            return edge
        }

        return AdventureLayer(type: .initial, state: .growing, vertices: vertices, edges: edges, entrance: entrance)
    }

    private static func vertexFor(_ proto: VertexPrototype, layout: AdventureLayout) -> Vertex {
        let state: VertexState = proto.role == .entrance ? .active() : .seed
        let point = (layout.vertices[proto.id] ?? .zero)
        let id = proto.id + UUID().uuidString
        let vertex = Vertex(id: id, state: state, point: point, resources: proto.resources)
        return vertex
    }
}
