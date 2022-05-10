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

indirect enum ResourceState {
    case vertex(vertex: Vertex, index: Int, total: Int)
    case inventory(player: Player, index: Int, estimatedIndex: Int, total: Int, isFresh: Bool) // "Fresh" means gathered at last turn
    case gate(gate: EdgeGate, edge: Edge, fromVertex: Vertex, fromIndex: Int, state: ResourceOnGateState, prestate: ResourceState)
    case deletion // This state sets before resource will be deleted to notify view layer
    
    var short: String {
        switch self {
        case .inventory: return "i"
        case .gate: return "g"
        case .vertex: return "v"
        case .deletion: return "d"
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

extension Array where Element == Resource {
    mutating func removeAllDeletion() {
        self = filter {
            switch $0.state {
            case .deletion:
                return false
            default:
                return true
            }
        }
    }
}
