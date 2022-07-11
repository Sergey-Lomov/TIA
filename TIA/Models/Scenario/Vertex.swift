//
//  Vertex.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation
import CoreGraphics
import Combine

enum VertexAction {
    case completeAdventure
    case exit
    case restart
}

enum LayerChangeType: Equatable {
    case presenting
    case hiding
}

enum VertexVisitPhase: Equatable {
    case income(edge: Edge)
    case onVertex
    case outcome
}

struct VertexVisit: Equatable {
    let visitor: Player
    let phase: VertexVisitPhase
}

struct VertexLayerTransfer: Equatable {
    let from: AdventureLayer
    let to: AdventureLayer
    let type: LayerChangeType
}

enum VertexState: Equatable {
    case seed
    case growing
    case active(visit: VertexVisit? = nil, layerTransfer: VertexLayerTransfer? = nil)
    case ungrowing

    var isGrowed: Bool {
        switch self {
        case .seed, .growing, .ungrowing:
            return false
        case .active:
            return true
        }
    }

    var isVisible: Bool {
        switch self {
        case .seed:
            return false
        case .active, .growing, .ungrowing:
            return true
        }
    }
}

class Vertex: ObservableObject, IdEqutable {
    var id: String
    var onVisit: VertexAction?
    var actions: [VertexAction] = []

    @Published var state: VertexState
    @Published var point: CGPoint
    var initialResources: [ResourceType]

    init(id: String, state: VertexState = .seed, point: CGPoint = .zero, resources: [ResourceType] = []) {
        self.id = id
        self.state = state
        self.point = point
        self.initialResources = resources
    }

    func updateVisitInfo(_ visit: VertexVisit?) {
        guard case .active(_, let transfer) = state else { return }
        state = .active(visit: visit, layerTransfer: transfer)
    }

    func mergeWith(_ vertex: Vertex) {
        actions.append(contentsOf: vertex.actions)
        onVisit = vertex.onVisit
        initialResources = vertex.initialResources
    }
}
