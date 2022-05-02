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
        guard let index = edge.gates.firstIndex(where: {$0.id == gate.id}) else {
            return .zero
        }
        return gatePosition(geometry, edge: edge, index: index)
    }
    
    static func gatePosition(_ geometry: GeometryProxy, edge: Edge, index: Int) -> CGPoint {
        let curve = edge.curve.scaled(geometry)
        let ratio = CGFloat(index + 1) / CGFloat(edge.gates.count + 1)
        return curve.getPoint(lengthRatio: ratio)
    }
}
