//
//  ScenarioService.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation
import CoreGraphics

class ScenarioService {
    
    static var shared = ScenarioService()
    
    func restoreScenario() -> Scenario {
        let states = StorageService.shared.getAdventuresStates()
        
        let protoScenario = JSONDecoder().decodeScenario()
        let adventures = protoScenario.adventures.map {
            adventure(id: $0)
        }
        
        return Scenario(adventures: adventures)
    }
    
    private func adventure(id: String) -> Adventure {
        let protoAdventure = JSONDecoder().decodeAdventure(id: id)
        
        let vertices = protoAdventure.vertices.map {
            Vertex(id: $0.id, type: $0.type, resources: $0.resources)
        }
        
        let edges: [Edge] = protoAdventure.edges.map {
            guard let from = vertices.firstById($0.fromId),
                  let to = vertices.firstById($0.toId) else {
                fatalError("Missed vertex connected to edge \"\($0.id)\"")
            }
            
            return Edge(id: $0.id,
                        from: from,
                        to: to,
                        price: $0.price,
                        growOnStart: $0.growOnStart)
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
        let resources: [Resource]
    }
    
    struct EdgePrototype: Codable {
        let id: String
        let fromId: String
        let toId: String
        let price: [Resource]
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
