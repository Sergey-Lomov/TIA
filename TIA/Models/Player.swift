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

class Player: ObservableObject {
    @Published var position: PlayerPosition
    var id = UUID().uuidString
    
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
        guard case .edge(let edge, let status, let dir) = position, status == .moving else {
            return
        }
        
        position = .edge(edge: edge, status: .expanding, direction: dir)
    }
    
    func expandingFinished() {
        guard case .edge(let edge, let status, let dir) = position, status == .expanding else {
            return
        }
        
        if dir == .forward {
            position = .vertex(vertex: edge.to)
        } else {
            position = .vertex(vertex: edge.from)
        }
    }
}
