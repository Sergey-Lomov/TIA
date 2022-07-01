//
//  ScenarioService.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation
import CoreGraphics

final class ScenarioService {
    
    static var shared = ScenarioService()
    
    func restoreScenario() -> Scenario {
        let states = StorageService.shared.getAdventuresStates()
        
        let protoScenario = JSONDecoder.decodeScenario()
        let adventures: [AdventureDescriptor] = protoScenario.adventures.map {
            let adventure = adventureDescriptor(id: $0)
            adventure.state = states[adventure.id] ?? .planed
            return adventure
        }
        
        return Scenario(adventures: adventures)
    }
    
    private func adventureDescriptor(id: String) -> AdventureDescriptor {
        let prototype = JSONDecoder.decodeAdventure(id: id)
        return AdventureDescriptor(id: prototype.id, index: prototype.index, theme: prototype.theme, doneShape: prototype.doneShape)
    }
    
    func layerFor(_ descriptor: AdventureDescriptor, layout: AdventureLayout, forcedEntrance: Vertex? = nil) -> AdventureLayer {
        return layerFor(descriptor.id, layout: layout, forcedEntrance: forcedEntrance)
    }
        
    func layerFor(_ id: String, layout: AdventureLayout, forcedEntrance: Vertex? = nil) -> AdventureLayer {
        var protoAdventure = JSONDecoder.decodeAdventure(id: id)
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
    
    func adventureFor(_ descriptor: AdventureDescriptor, layout: AdventureLayout) -> Adventure {
        let prototype = JSONDecoder.decodeAdventure(id: descriptor.id)
        let layer = layerFor(descriptor, layout: layout, forcedEntrance: nil)
        return Adventure(id: prototype.id, index: prototype.index, theme: prototype.theme, initialLayer: layer, doneShape: prototype.doneShape)
    }
    
    private func vertexFor(_ proto: VertexPrototype, layout: AdventureLayout) -> Vertex {
        let state: VertexState = proto.role == .entrance ? .active() : .seed
        let point = (layout.vertices[proto.id] ?? .zero)
        let id = proto.id + UUID().uuidString
        let vertex = Vertex(id: id, state: state, point: point, resources: proto.resources)
        return vertex
    }

// MARK: Codable prototypes
    
    enum VertexRole: String, Codable {
        case entrance
        case common
        case exit
    }
    
    struct VertexPrototype: Codable {
        var id: String
        let role: VertexRole
        let resources: [ResourceType]
    }
    
    struct EdgePrototype: Codable {
        let id: String
        var from: String
        var to: String
        let price: [ResourceType]
        let growOnStart: Bool
    }
    
    struct AdventurePrototype: Codable {
        let id: String
        let index: Int
        let theme: AdventureTheme
        let doneShape: AdventureDoneShape
        var vertices: [VertexPrototype]
        var edges: [EdgePrototype]
        
        mutating func updateVertexId(_ id: String, to newId: String) {
            for i in 0..<vertices.count where vertices[i].id == id {
                vertices[i].id = newId
            }
            for i in 0..<edges.count {
                if edges[i].from == id { edges[i].from = newId }
                if edges[i].to == id { edges[i].to = newId }
            }
        }
    }
    
    struct ScenarioPrototype: Codable {
        let adventures: [String]
    }
}
