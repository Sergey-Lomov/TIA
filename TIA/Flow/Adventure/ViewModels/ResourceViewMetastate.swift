//
//  ResourceViewMetastate.swift
//  TIA
//
//  Created by serhii.lomov on 11.05.2022.
//

import Foundation

// TODO: Check is this solution (flating nested switch) really useful or not
enum ResourceMetastate {
    case abscent
    case vertex(vertex: Vertex, index: Int, total: Int)
    case vertexIdle(vertex: Vertex, index: Int, total: Int)
    case vertexRestoring(vertex: Vertex, index: Int, total: Int)
    case outFromVertex(vertex: Vertex, index: Int, playerEdge: Edge)
    case inventoryAtVertex(vertex: Vertex, index: Int)
    case successMoving(edge: Edge, forward: Bool, fromIndex: Int, toIndex: Int, total: Int)
    case failedNear(gate: EdgeGate, edge: Edge, vertex: Vertex, index: Int, total: Int)
    case toGate(gate: EdgeGate, edge: Edge, fromVertex: Vertex, fromIndex: Int)
    case onGate(gate: EdgeGate, edge: Edge)
    case fromGate(gate: EdgeGate, edge: Edge, toVertex: Vertex, toIndex: Int)
    case prelayerChanging(vertex: Vertex, index: Int, oldLayer: AdventureLayer)
    case layerChanging(vertex: Vertex, index: Int, newLayer: AdventureLayer, type: LayerChangeType)
    case predestroying(from: Vertex, index: Int)
    case destroying(from: Vertex, index: Int, total: Int)

    var positionAnimated: Bool {
        switch self {
        case .successMoving, .failedNear, .toGate, .fromGate:
            return true
        default:
            return false
        }
    }
}

extension ResourceState {
    var animationIntermediate: Bool {
        switch self {
        case .inventory(let player, _, _, _, _):
            switch player.metastate {
            case .movingFromGate, .movingToGate:
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
    
    var metastate: ResourceMetastate {
        switch self {
        case .vertex(let vertex, let index, let total, let idleState):
            switch idleState {
            case .none:
                return .vertex(vertex: vertex, index: index, total: total)
            case .rotation:
                return .vertexIdle(vertex: vertex, index: index, total: total)
            case .restoring:
                return .vertexRestoring(vertex: vertex, index: index, total: total)
            }
        
        case .gate(let gate, let edge, let vertex, let index, let state, _):
            switch state {
            case .incoming:
                return .toGate(gate: gate, edge: edge, fromVertex: vertex, fromIndex: index)
            case .stay:
                return .onGate(gate: gate, edge: edge)
            case .outcoming:
                return .fromGate(gate: gate, edge: edge, toVertex: vertex, toIndex: index)
            }
        
        case .inventory(let player, let index, let estimated, let total, let isFresh):
            switch player.metastate {
            
            case .abscent:
                return .abscent
            
            case .vertex(let vertex),
                    .compressing(let vertex),
                    .expanding(let vertex):
                switch vertex.state.metastate {
                case .layerTransfer(let info):
                    if info.to.state == .preparing {
                        return .prelayerChanging(vertex: vertex, index: index, oldLayer: info.from)
                    } else {
                        return .layerChanging(vertex: vertex, index: index, newLayer: info.to, type: info.type)
                    }
                default:
                    return .inventoryAtVertex(vertex: vertex, index: index)
                }
           
            case .moving(let edge, let forward):
                if isFresh {
                    let vertex = forward ? edge.to : edge.from
                    return .outFromVertex(vertex: vertex, index: index, playerEdge: edge)
                } else {
                    return .successMoving(edge: edge, forward: forward, fromIndex: index, toIndex: estimated, total: total)
                }
            
            case .movingToGate(let gate, let edge, let forward):
                let vertex = forward ? edge.from : edge.to
                return .failedNear(gate: gate, edge: edge, vertex: vertex, index: index, total: total)
            case .movingFromGate(let gate, let edge, let forward):
                let vertex = forward ? edge.from : edge.to
                return .failedNear(gate: gate, edge: edge, vertex: vertex, index: index, total: total)
            }
            
        case .destroying(let from, let index, let total, let phase):
            switch phase {
            case .preparing:
                return .predestroying(from: from, index: index)
            case .moving:
                return .destroying(from: from, index: index, total: total)
            }
        }
    }
}

extension ResourceViewModel {
    var metastate: ResourceMetastate {
        state?.metastate ?? .abscent
    }
}
