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

enum ResourceMoveOutState {
    case preparing
    case moving
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
    case destroying(from: Vertex, index: Int, total: Int, state: ResourceMoveOutState)

    #if DEBUG
    var short: String {
        switch self {
        case .inventory: return "i"
        case .gate: return "g"
        case .vertex: return "v"
        case .destroying: return "o"
        }
    }
    #endif
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
