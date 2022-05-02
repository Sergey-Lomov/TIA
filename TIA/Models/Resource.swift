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

enum ResourceState {
    case vertex(vertex: Vertex, index: Int, total: Int)
    case inventory(player: Player, index: Int, estimatedIndex: Int, total: Int, isFresh: Bool) // "Fresh" means gathered at last turn
    case gate(gate: EdgeGate, edge: Edge, fromVertex: Vertex, fromIndex: Int)
}

class Resource: ObservableObject {
    var type: ResourceType
    @Published var state: ResourceState
    
    init(type: ResourceType, state: ResourceState) {
        self.type = type
        self.state = state
    }
}
