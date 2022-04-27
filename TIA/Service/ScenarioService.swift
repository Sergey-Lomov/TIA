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
        let protoAdventure = JSONDecoder.decodeAdventure(id: id)
        return AdventureDescriptor(id: protoAdventure.id,
                                   index: protoAdventure.index,
                                   theme: protoAdventure.theme)
    }
    
    func adventureFor(_ descriptor: AdventureDescriptor, layout: AdventureLayout) -> Adventure {
        let protoAdventure = JSONDecoder.decodeAdventure(id: descriptor.id)
        
        let vertices: [Vertex] = protoAdventure.vertices.map {
            
            let state: VertexState = $0.type == .entrance ? .active : .seed
            let point = layout.vertices[$0.id] ?? .zero
            return Vertex(id: $0.id,
                          type: $0.type,
                          state: state,
                          point: point,
                          resources: $0.resources)
        }

        let edges: [Edge] = protoAdventure.edges.map {
            guard let from = vertices.firstById($0.from),
                  let to = vertices.firstById($0.to) else {
                fatalError("Missed vertex connected to edge \"\($0.id)\"")
            }
             
            let p1 = layout.edges[$0.id]?.p1 ?? from.point
            let p2 = layout.edges[$0.id]?.p2 ?? to.point
            let curve = BezierCurve(points: [from.point, p1, p2, to.point])
            let edge = Edge(id: $0.id,
                            from: from,
                            to: to,
                            price: $0.price,
                            growOnStart: $0.growOnStart,
                            curve: curve)
            
            from.outEdges.append(edge)
            to.inEdges.append(edge)

            return edge
        }
        
        return Adventure(id: protoAdventure.id,
                         index: protoAdventure.index,
                         theme: protoAdventure.theme,
                         vertices: vertices,
                         edges: edges)
    }

// MARK: Codable prototypes
    
    struct VertexPrototype: Codable {
        let id: String
        let type: VertexType
        let resources: [ResourceType]
    }
    
    struct EdgePrototype: Codable {
        let id: String
        let from: String
        let to: String
        let price: [ResourceType]
        let growOnStart: Bool
    }
    
    struct AdventurePrototype: Codable {
        let id: String
        let index: Int
        let theme: AdventureTheme
        let vertices: [VertexPrototype]
        let edges: [EdgePrototype]
    }
    
    struct ScenarioPrototype: Codable {
        let adventures: [String]
    }
}
