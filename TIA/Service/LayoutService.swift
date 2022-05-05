//
//  LayoutService.swift
//  TIA
//
//  Created by serhii.lomov on 02.05.2022.
//

import Foundation
import SwiftUI

final class LayoutService {
    static func gatePosition(_ geometry: GeometryProxy, edge: Edge, gate: EdgeGate) -> CGPoint {
        guard let index = edge.gates.firstIndex(of: gate) else {
            return .zero
        }
        return gatePosition(geometry, edge: edge, index: index)
    }
    
    static func gateProgress(_ geometry: GeometryProxy, edge: Edge, index: Int) -> CGFloat {
        let curve = edge.curve.scaled(geometry)
        let ratio = CGFloat(index + 1) / CGFloat(edge.gates.count + 1)
        return curve.getT(lengthRatio: ratio)
    }
    
    static func gatePosition(_ geometry: GeometryProxy, edge: Edge, index: Int) -> CGPoint {
        let progress = gateProgress(geometry, edge: edge, index: index)
        return edge.curve.scaled(geometry).getPoint(t: progress)
    }
    
    static func vertexResourceSize(_ geometry: GeometryProxy) -> CGSize {
        CGSize(Layout.Vertex.diameter * Layout.Resources.Vertex.sizeRatio).scaled(geometry.minSize)
    }
    
    static func gateResourceSize(_ geometry: GeometryProxy) -> CGSize {
        CGSize(Layout.EdgeGate.sizeRatio * Layout.EdgeGate.symbolRatio).scaled(geometry.minSize)
    }
    
    static func inventoryResourceSize(_ geometry: GeometryProxy) -> CGSize {
        CGSize(Layout.Vertex.diameter * Layout.Resources.Player.sizeRatio).scaled(geometry.minSize)
    }
}
