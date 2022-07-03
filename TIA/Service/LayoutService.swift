//
//  LayoutService.swift
//  TIA
//
//  Created by serhii.lomov on 02.05.2022.
//

import Foundation
import SwiftUI

final class LayoutService {

    static func currentAdventureIconPosition(theme: AdventureTheme) -> CGPoint {
        switch theme {
        case .dark:
            return CGPoint(x: 0, y: -1 * Layout.MainMenu.currentIconY)
        case .light:
            return CGPoint(x: 0, y: Layout.MainMenu.currentIconY)
        case .truth:
            return .zero
        }
    }

    static func gateProgress(_ geometry: GeometryProxy, gate: EdgeGate, edge: Edge) -> CGFloat {
        guard let index = edge.gates.firstIndex(of: gate) else { return .zero }
        let curve = edge.curve.scaled(geometry)
        let ratio = CGFloat(index + 1) / CGFloat(edge.gates.count + 1)
        return curve.getT(lengthRatio: ratio)
    }

    static func gatePosition(_ geometry: GeometryProxy, gate: EdgeGate, edge: Edge) -> CGPoint {
        let progress = gateProgress(geometry, gate: gate, edge: edge)
        return edge.curve.scaled(geometry).getPoint(t: progress)
    }

    static func vertexResourceSize(_ geometry: GeometryProxy) -> CGSize {
        CGSize(Layout.Vertex.diameter * Layout.Resources.Vertex.sizeRatio).scaled(geometry.minSize)
    }

    static func gateResourceSize(_ geometry: GeometryProxy) -> CGSize {
        CGSize(Layout.EdgeGate.sizeRatio * Layout.EdgeGate.symbolRatio).scaled(geometry.minSize)
    }

    static func inventoryResourceSize(_ geometry: GeometryProxy) -> CGSize {
        inventoryResourceSize(geometry.size)
    }

    static func inventoryResourceSize(_ size: CGSize) -> CGSize {
        let relativeSize = Layout.Vertex.diameter * Layout.Resources.Player.sizeRatio
        return CGSize(relativeSize).scaled(size.minSize)
    }
}
