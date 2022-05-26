//
//  CameraService.swift
//  TIA
//
//  Created by serhii.lomov on 23.05.2022.
//

import Foundation
import SwiftUI

enum CameraStatus {
    case fixed(state: CameraState)
    case transition(to: CameraState, animation: Animation?)
    
    var state: CameraState {
        switch self {
        case .fixed(let state):
            return state
        case .transition(let to, _):
            return to
        }
    }
}

struct CameraState {
    let center: CGPoint
    let zoom: CGFloat
    
    static var `default` = CameraState(center: .zero, zoom: 1)
}

final class CameraService {
    let screenSize: CGSize
    
    init(size: CGSize) {
        self.screenSize = size
    }
    
    func initial(adventure: Adventure) -> CameraStatus {
        return .fixed(state: .default)
    }
    
    func showMenu(from: Vertex) -> CameraStatus {
        let zoom = Layout.Menu.vertexDiameter / Layout.Vertex.diameter
        let animation = AnimationService.shared.showMenu
        return centrateVertex(from, zoom: zoom, animation: animation)
    }
    
    func centrateVertex(_ vertex: Vertex, zoom: CGFloat, animation: Animation?) -> CameraStatus {
        let center = vertex.point.scaled(screenSize).mirrored()
        let state = CameraState(center: center, zoom: zoom)
        return .transition(to: state, animation: animation)
    }
}
