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
    case pretransition(from: CameraState, to: CameraState, animation: Animation?)
    case transition(to: CameraState, animation: Animation?)
}

struct CameraState {
    let center: CGPoint
    let zoom: CGFloat
    let angle: CGFloat
    
    init (center: CGPoint, zoom: CGFloat = 1, angle: CGFloat = 0) {
        self.center = center
        self.zoom = zoom
        self.angle = angle
    }
    
    static var `default` = CameraState(center: .zero)
}

final class CameraService {
    let screenSize: CGSize
    
    private var border: CGFloat { Layout.Adventure.border * screenSize.minSize }
    
    init(size: CGSize) {
        self.screenSize = size
    }
    
    func initial(adventure: Adventure) -> CameraState {
        return .default
    }
    
    func forLayer(_ layer: AdventureLayer, focusPoint: CGPoint) -> CameraState {
        let scaledFocus = focusPoint.scaled(screenSize)
        let focusFrame = CGRect(center: scaledFocus, size: screenSize)
        let rawLayerFrame = layerFrame(layer)
        let layerFrame = CGRect(center: rawLayerFrame.center, size: screenSize)
        let deltaWidth = layerFrame.width - focusFrame.width
        let deltaHeight = layerFrame.height - focusFrame.height
        let availableSize = CGSize(width: deltaWidth, height: deltaHeight)
        let availableFrame = CGRect(origin: layerFrame.origin, size: availableSize)
        let origin = availableFrame.nearestPoint(to: focusFrame.origin)
        let center = origin.translated(by: screenSize.half)
        return .init(center: center)
    }
    
    func focusOnAdventureZoom() -> CGFloat {
        let size = Math.rectSize(ratio: screenSize.ratio, circumscribedRadius: Layout.MainMenu.pickerSize / 4)
        let xScale = screenSize.width / size.width
        let yScale = screenSize.height / size.height
        return max(xScale, yScale)
    }
    
    func focusOnCurrentAdventure(_ theme: AdventureTheme) -> CameraState {
        var center = LayoutService.currentAdventureIconPosition(theme: theme)
        center = center.scaled(Layout.MainMenu.pickerSize)
        return .init(center: center, zoom: focusOnAdventureZoom(), angle: .hpi)
    }
    
    func focusOnVertex(_ vertex: Vertex) -> CameraState {
        let center = vertex.point.scaled(screenSize)
        return .init(center: center)
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
}
