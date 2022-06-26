//
//  CameraService.swift
//  TIA
//
//  Created by serhii.lomov on 23.05.2022.
//

import Foundation
import SwiftUI

final class CameraService {
    let fullSize: CGSize
    let safeSize: CGSize
    
    private var border: CGFloat { Layout.Adventure.border * safeSize.minSize }
    
    init(safe: CGSize, full: CGSize) {
        self.safeSize = safe
        self.fullSize = full
    }
    
    func initial(adventure: Adventure) -> CameraState {
        return .default
    }
    
    func forLayer(_ layer: AdventureLayer, focusPoint: CGPoint) -> CameraState {
        let scaledFocus = focusPoint.scaled(safeSize)
        let focusFrame = CGRect(center: scaledFocus, size: safeSize)
        let rawLayerFrame = layerFrame(layer)
        let layerFrame = CGRect(center: rawLayerFrame.center, size: safeSize)
        let deltaWidth = layerFrame.width - focusFrame.width
        let deltaHeight = layerFrame.height - focusFrame.height
        let availableSize = CGSize(width: deltaWidth, height: deltaHeight)
        let availableFrame = CGRect(origin: layerFrame.origin, size: availableSize)
        let origin = availableFrame.nearestPoint(to: focusFrame.origin)
        let center = origin.translated(by: safeSize.half)
        return .init(center: center)
    }
    
    func focusOnAdventureZoom() -> CGFloat {
        let size = Math.rectSize(ratio: fullSize.ratio, circumscribedRadius: Layout.MainMenu.pickerSize / 4)
        let xScale = safeSize.width / size.width
        let yScale = safeSize.height / size.height
        return max(xScale, yScale)
    }
    
    func focusOnCurrentAdventure(_ theme: AdventureTheme) -> CameraState {
        var center = LayoutService.currentAdventureIconPosition(theme: theme)
        center = center.scaled(Layout.MainMenu.pickerSize)
        return .init(center: center, zoom: focusOnAdventureZoom(), angle: .hpi)
    }
    
    func focusOnVertex(_ vertex: Vertex) -> CameraState {
        let center = vertex.point.scaled(safeSize)
        return .init(center: center)
    }
    
    // TODO: Cash layer frame calculations
    private func layerFrame(_ layer: AdventureLayer) -> CGRect {
        let entrancePoint = layer.entrance.point.scaled(safeSize)
        var frame = CGRect(origin: entrancePoint, size: .zero)
        
        layer.vertices.forEach {
            let diameter = Layout.Vertex.diameter * safeSize.minSize
            let center = $0.point.scaled(safeSize)
            let vertexFrame = CGRect(center: center, size: CGSize(diameter))
            frame = frame.union(vertexFrame)
        }
        
        layer.edges.forEach {
            let edgeFrame = $0.curve.scaled(safeSize).frame()
            frame = frame.union(edgeFrame)
        }
        
        return frame.insetBy(dx: -1 * border, dy: -1 * border)
    }
}
