//
//  EdgeViewMetastate.swift
//  TIA
//
//  Created by serhii.lomov on 16.05.2022.
//

import Foundation

enum EdgeViewMetastate {
    case seed
    case preextendedSeed
    case extendedSeed
    case pregrowing
    case growPath(duration: TimeInterval)
    case waitingVertex
    case pregrowingElements
    case growElements(duration: TimeInterval)
    case active
    case preungrowing
    case ungrowElements(duration: TimeInterval)
    case ungrowPath(duration: TimeInterval)
    
    static func forState(_ state: EdgeState) -> EdgeViewMetastate {
        switch state {
        case .seed(let phase):
            switch phase {
            case .compressed:
                return .seed
            case .preextended:
                return .preextendedSeed
            case .extended:
                return .extendedSeed
            }
        case .growing(let phase):
            switch phase {
            case .preparing:
                return .pregrowing
            case .pathGrowing(let duration):
                return .growPath(duration: duration)
            case .waitingDestinationVertex:
                return .waitingVertex
            case .preparingElements:
                return .pregrowingElements
            case .elementsGrowing(let duration):
                return .growElements(duration: duration)
            }
        case .active:
            return .active
        case .ungrowing(let phase):
            switch phase {
            case .preparing:
                return .preungrowing
            case .elementsUngrowing(let duration):
                return .ungrowElements(duration: duration)
            case .pathUngrowing(let duration):
                return .ungrowPath(duration: duration)
            }
        }
    }
    
    var fromConnectorVisible: Bool {
        switch self {
        case .seed:
            return false
        default:
            return true
        }
    }
    
    var toConnectorVisible: Bool {
        switch self {
        case .seed, .preextendedSeed, .extendedSeed, .pregrowing, .growPath, .waitingVertex, .ungrowPath:
            return false
        default:
            return true
        }
    }
}

extension EdgeViewModel {
    var metastate: EdgeViewMetastate { EdgeViewMetastate.forState(model.state) }
}
