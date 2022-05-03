//
//  Player.swift
//  TIA
//
//  Created by Serhii.Lomov on 22.04.2022.
//

import Foundation

// TODO: this may be part of view model, not part of core model
enum EdgeMovingStatus {
    case compressing
    case moving
    case expanding
}


enum EdgeMovingDirection {
    case forward
    case backward
    case forwardFail(gateIndex: Int, moveToGate: Bool)
    case backwardFail(gateIndex: Int, moveToGate: Bool)
    
    var isForward: Bool {
        switch self {
        case .forward, .forwardFail:
            return true
        case .backward, .backwardFail:
            return false
        }
    }
    
    func startVertex(_ edge: Edge) -> Vertex {
        switch self {
        case .forward, .forwardFail: return edge.from
        case .backward, .backwardFail: return edge.to
        }
    }
    
    func endVertex(_ edge: Edge) -> Vertex {
        switch self {
        case .forward, .backwardFail: return edge.to
        case .backward, .forwardFail: return edge.from
        }
    }
}

enum PlayerPosition {
    case abscent
    case edge(edge: Edge, status: EdgeMovingStatus, direction: EdgeMovingDirection)
    case vertex(vertex: Vertex)
    
    var isAbscent: Bool {
        switch self {
        case .abscent:
            return true
        default:
            return false
        }
    }
    
    var currnetEdge: Edge? {
        switch self {
        case .edge(let edge, let status, _):
            if status == .moving {
                return edge
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}

class Player: ObservableObject, IdEqutable {
    
    var id = UUID().uuidString
    @Published var position: PlayerPosition
    
    init(position: PlayerPosition) {
        self.position = position
    }
    
    func compressingFinished() {
        guard case .edge(let edge, let status, let dir) = position, status == .compressing else {
            return
        }
        
        position = .edge(edge: edge, status: .moving, direction: dir)
    }
    
    func movingFinished() {
        guard case .edge(let edge, let status, let direction) = position, status == .moving else {
            return
        }
        
        switch direction {
        case .forward, .backward:
            position = .edge(edge: edge, status: .expanding, direction: direction)
        case .forwardFail(_, let moveToGate),
                .backwardFail(_, let moveToGate):
            if moveToGate {
                position = .edge(edge: edge, status: .moving, direction: invertFail(direction))
            } else {
                position = .edge(edge: edge, status: .expanding, direction: direction)
            }
        }
    }
    
    private func invertFail(_ direction: EdgeMovingDirection) -> EdgeMovingDirection {
        switch direction {
        case .forward:
            return .backward
        case .backward:
            return .forward
        case .forwardFail(let gateIndex, let moveToGate):
            return .forwardFail(gateIndex: gateIndex, moveToGate: !moveToGate)
        case .backwardFail(let gateIndex, let moveToGate):
            return .backwardFail(gateIndex: gateIndex, moveToGate: !moveToGate)
        }
    }
    
    func expandingFinished() {
        guard case .edge(let edge, let status, let direction) = position, status == .expanding else {
            return
        }
        
        let vertex = direction.endVertex(edge)
        position = .vertex(vertex: vertex)
    }
}
