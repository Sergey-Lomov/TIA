//
//  VertexViewMetastate.swift
//  TIA
//
//  Created by serhii.lomov on 16.06.2022.
//

import Foundation
import CoreGraphics

enum VertexViewMetastate {
    case seed
    case growing
    case ungrowing
    case active
    case playerIncome(edge: Edge)
    case occupied
    case layerTransfer(info: VertexLayerTransfer)
}

extension VertexState {
    
    var metastate: VertexViewMetastate {
        switch self {
        case .seed:
            return .seed
        case .growing:
            return .growing
        case .ungrowing:
            return .ungrowing
        case .active(let visit, let layerTransfer):
            if let transfer = layerTransfer {
                return .layerTransfer(info: transfer)
            }
            if let visit = visit {
                if case .income(let edge) = visit.phase {
                    return .playerIncome(edge: edge)
                }
                return .occupied
            }
            return .active
        }
    }
}

extension VertexViewModel {
    var metastate: VertexViewMetastate { state.metastate }
}
