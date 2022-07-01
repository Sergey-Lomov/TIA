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
    case growPath
    case waitingVertex
    case pregrowingElements
    case growElements
    case active
    case preungrowing
    case ungrowElements
    case ungrowPath

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
            case .pathGrowing:
                return .growPath
            case .waitingDestinationVertex:
                return .waitingVertex
            case .preparingElements:
                return .pregrowingElements
            case .elementsGrowing:
                return .growElements
            }
        case .active:
            return .active
        case .ungrowing(let phase):
            switch phase {
            case .preparing:
                return .preungrowing
            case .elementsUngrowing:
                return .ungrowElements
            case .pathUngrowing:
                return .ungrowPath
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
