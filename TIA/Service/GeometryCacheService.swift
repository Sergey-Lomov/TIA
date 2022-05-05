//
//  CacheService.swift
//  TIA
//
//  Created by serhii.lomov on 05.05.2022.
//

import Foundation
import CoreGraphics

final class GeometryCacheService {
    
    static var shared = GeometryCacheService()
    
    var failNearGateCache: [String: [CGPoint]] = [:]
    
    func failNearGate(gate: EdgeGate, vertex: Vertex) -> [CGPoint]? {
        let key = gate.id + vertex.id
        return failNearGateCache[key]
    }
    
    func setFailNearGate(gate: EdgeGate, vertex: Vertex, controls: [CGPoint]) {
        let key = gate.id + vertex.id
        failNearGateCache[key] = controls
    }
    
    func invalidateFailNearGate(gate: EdgeGate, vertex: Vertex) {
        let key = gate.id + vertex.id
        failNearGateCache[key] = nil
    }
}
