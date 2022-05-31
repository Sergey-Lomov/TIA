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
    
    private var border: CGFloat { Layout.Adventure.border * screenSize.minSize }
    
    init(size: CGSize) {
        self.screenSize = size
    }
    
    func initial(adventure: Adventure) -> CameraStatus {
        return .fixed(state: .default)
    }
    
    func forLayer(_ layer: AdventureLayer, focusPoint: CGPoint) -> CameraState {
        let scaledFocus = focusPoint.scaled(screenSize)
        let focusFrame = CGRect(center: scaledFocus, size: screenSize)
        let rawLayerFrame = layerFrame(layer)
        let layerFrame = CGRect(center: rawLayerFrame.center, size: screenSize)
        let x = max(layerFrame.minX, focusFrame.minX)
        let y = max(layerFrame.minY, focusFrame.minY)
        let center = CGPoint(x: x, y: y).translated(by: screenSize.half)
        return .init(center: center, zoom: 1)
    }
    
    // TODO: Cash layer frame calculations
    private func layerFrame(_ layer: AdventureLayer) -> CGRect {
        let entrancePoint = layer.entrance.point.scaled(screenSize)
        var frame = CGRect(origin: entrancePoint, size: .zero)
        
        layer.vertices.forEach {
            let diameter = Layout.Vertex.diameter * screenSize.minSize
            let center = $0.point.scaled(screenSize)
            let vertexFrame = CGRect(center: center, size: CGSize(diameter))
            frame = frame.union(vertexFrame)
        }
        
        layer.edges.forEach {
            let edgeFrame = $0.curve.scaled(screenSize).frame()
            frame = frame.union(edgeFrame)
        }
        
        return frame.insetBy(dx: -1 * border, dy: -1 * border)
    }
//
//    func showMenu(from: Vertex) -> CameraStatus {
//        let animation = AnimationService.shared.showMenu
//        return centrateVertex(from, zoom: Layout.Menu.zoom, animation: animation)
//    }
//
//    func centrateVertex(_ vertex: Vertex, zoom: CGFloat, animation: Animation?) -> CameraStatus {
//        let center = vertex.point.scaled(screenSize).mirrored()
//        let state = CameraState(center: center, zoom: zoom)
//        return .transition(to: state, animation: animation)
//    }
}
