//
//  Player.swift
//  TIA
//
//  Created by serhii.lomov on 04.05.2022.
//

import Foundation

enum PlayerMetastate {
    case abscent
    case vertex(vertex: Vertex)
    case compressing(vertex: Vertex)
    case expanding(vertex: Vertex)
    case moving(edge: Edge, forward: Bool)
    case movingToGate(edge: Edge, index: Int, forward: Bool)
    case movingFromGate(edge: Edge, index: Int, forward: Bool)
}

extension Player {
    var metastate: PlayerMetastate {
        switch position {
        case .abscent:
            return .abscent
        case .vertex(let vertex):
            return .vertex(vertex: vertex)
        case .edge(let edge, let status, let direction):
            let forward = direction.isForward
            switch status {
            case .compressing:
                let start = direction.startVertex(edge)
                return .compressing(vertex: start)
            case .moving:
                switch direction {
                case .forward, .backward:
                    return .moving(edge: edge, forward: forward)
                case .forwardFail(let gateIndex, let moveToGate),
                    .backwardFail(let gateIndex, let moveToGate):
                    if moveToGate {
                        return .movingToGate(edge: edge, index: gateIndex, forward: forward)
                    } else {
                        return .movingFromGate(edge: edge, index: gateIndex, forward: forward)
                    }
                }
            case .expanding:
                let end = direction.endVertex(edge)
                return .expanding(vertex: end)
            }
        }
    }
}
