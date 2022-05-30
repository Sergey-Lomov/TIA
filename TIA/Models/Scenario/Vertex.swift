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
    case exit
    case restart
}

enum VertexState {
    case seed
    case growing(duration: TimeInterval)
    case active
    
    var isGrowed: Bool {
        switch self {
        case .seed, .growing:
            return false
        case .active:
            return true
        }
    }
}

class Vertex: ObservableObject, IdEqutable {
    var id: String
    var onVisit: VertexAction?
    var actions: [VertexAction] = []
    
    @Published var state: VertexState
    var point: CGPoint
    var initialResources: [ResourceType]
    
    init(id: String, state: VertexState = .seed, point: CGPoint = .zero, resources: [ResourceType] = []) {
        self.id = id
        self.state = state
        self.point = point
        self.initialResources = resources
    }
}
