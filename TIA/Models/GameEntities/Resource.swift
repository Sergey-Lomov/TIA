//
//  Resource.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation

enum ResourceType: String, Codable {
    case despair
    case anger
    case yearning
    case inspiration
    case fun
    case love
}

enum ResourceOnGateState {
    case incoming
    case stay
    case outcoming
}

enum VertexIdleState {
    case none
    case rotation
    case restoring
}

indirect enum ResourceState {
    case vertex(vertex: Vertex, index: Int, total: Int, idle: VertexIdleState)
    case inventory(player: Player, index: Int, estimatedIndex: Int, total: Int, isFresh: Bool) // "Fresh" means gathered at last turn
    case gate(gate: EdgeGate, edge: Edge, fromVertex: Vertex, fromIndex: Int, state: ResourceOnGateState, prestate: ResourceState)
    case moveOut(from: Vertex, index: Int, total: Int)
    
    // TODO: Mark by debug code notation
    var short: String {
        switch self {
        case .inventory: return "i"
        case .gate: return "g"
        case .vertex: return "v"
        case .moveOut: return "o"
        }
    }
}

class Resource: ObservableObject, IdEqutable {
    let id = UUID().uuidString
    var type: ResourceType
    @Published var state: ResourceState
    
    init(type: ResourceType, state: ResourceState) {
        self.type = type
        self.state = state
    }
}
