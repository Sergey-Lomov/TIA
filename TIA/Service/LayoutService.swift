//
//  LayoutService.swift
//  TIA
//
//  Created by serhii.lomov on 02.05.2022.
//

import Foundation
import SwiftUI

final class LayoutService {
    
    // MARK: Gate related
    static func gatePosition(_ geometry: GeometryProxy, edge: Edge, gate: EdgeGate) -> CGPoint {
        let progress = gateProgress(geometry, edge: edge, gate: gate)
        return edge.curve.scaled(geometry).getPoint(t: progress)
    }
    
    static func gateProgress(_ geometry: GeometryProxy, edge: Edge, gate: EdgeGate) -> CGFloat {
        let curve = edge.curve.scaled(geometry)
        guard let index = edge.gates.firstIndex(of: gate) else { return .zero }
        let ratio = CGFloat(index + 1) / CGFloat(edge.gates.count + 1)
        return curve.getT(lengthRatio: ratio)
    }
//
//    static func gatePosition(_ geometry: GeometryProxy, edge: Edge, index: Int) -> CGPoint {
//        let progress = gateProgress(geometry, edge: edge, index: index)
//        return edge.curve.scaled(geometry).getPoint(t: progress)
//    }
    
    static func gateResourceSize(_ geometry: GeometryProxy) -> CGSize {
        CGSize(Layout.EdgeGate.sizeRatio * Layout.EdgeGate.symbolRatio).scaled(geometry.minSize)
    }
    
    // MARK: Vertex related
    static func vertexResourceSize(_ geometry: GeometryProxy) -> CGSize {
        CGSize(Layout.Vertex.diameter * Layout.Resources.Vertex.sizeRatio).scaled(geometry.minSize)
    }
    
    static func inventoryResourceSize(_ geometry: GeometryProxy) -> CGSize {
        CGSize(Layout.Vertex.diameter * Layout.Resources.Player.sizeRatio).scaled(geometry.minSize)
    }
    
    static func inVertextResourcePosition(_ geometry: GeometryProxy, slot: Int, total: Int) -> CGPoint {
        if total == 1 {
            return .zero
        } else {
            let angle = CGFloat.pi * 2.0 / CGFloat(total) * CGFloat(slot)
            var delta = CGPoint(x: cos(angle), y: sin(angle))
            delta.scale(by: Layout.Resources.Vertex.angleScale)
            return delta.scaled(geometry)
        }
    }
    
    static func resourceOffset(_ geometry: GeometryProxy, vertex: Vertex, slot: Int) -> CGPoint {
        let service = VertexSurroundingService(screenSize: geometry.size)
        let surrounding = service.surroundingFor(vertex, slotsCount: slot + 1)
        return surrounding.slots.last ?? .zero
    }
    
    static func resourcePosition(_ geometry: GeometryProxy, vertex: Vertex, slot: Int) -> CGPoint {
        let offset = LayoutService.resourceOffset(geometry, vertex: vertex, slot: slot)
        return vertex.point.scaled(geometry).translated(by: offset)
    }
}
