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
    case pregrowingCounterConnector
    case growCounterConnector(duration: TimeInterval)
    case active
    
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
            case .preparingCounterConnector:
                return .pregrowingCounterConnector
            case .counterConnectionGrowing(let duration):
                return .growCounterConnector(duration: duration)
            }
        case .active:
            return .active
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
        case .seed, .preextendedSeed, .extendedSeed, .pregrowing, .growPath, .waitingVertex:
            return false
        default:
            return true
        }
    }
}

extension EdgeViewModel {
    var metastate: EdgeViewMetastate { EdgeViewMetastate.forState(model.state) }
}
