//
//  CacheService.swift
//  TIA
//
//  Created by serhii.lomov on 03.07.2022.
//

import Foundation
import Accessibility
import SwiftUI

enum CacheCounter: Hashable, CaseIterable {
    case layerCamera
    case failNearGate
    case curveLength
    case surrounding
}

enum CacheId: Hashable {
    case layerCamera(_ layer: AdventureLayer)
    case failNearGate(_ gate: EdgeGate, _ vertex: Vertex)
    case curveLength(_ points: [CGPoint])
    case surrounding(_ vertex: Vertex, _ layer: AdventureLayer)

    var counter: CacheCounter {
        switch self {
        case .layerCamera: return .layerCamera
        case .failNearGate: return .failNearGate
        case .curveLength: return .curveLength
        case .surrounding: return .surrounding
        }
    }
}

final class CacheService {
    static var shared = CacheService()

    private let limits: [CacheCounter: Int] = [
        .failNearGate: 50,
        .surrounding: 100,
        .curveLength: 200,
        .layerCamera: 5
    ]
    private var caches: [CacheId: Any] = [:]
    private var counters: [CacheCounter: [CacheId: TimeInterval]]

    init() {
        counters = CacheCounter.allCases.reduce(into: [CacheCounter: [CacheId: TimeInterval]]()) {
            $0[$1] = [:]
        }
    }

    func cach(id: CacheId, value: Any) {
        if caches[id] == nil { caches[id] = [:] }
        caches[id] = value
        guard var ids = counters[id.counter] else { return }
        ids[id] = Date().timeIntervalSince1970

        let limit = limits[id.counter] ?? 0
        if ids.count > limit {
            let older = ids.min { $0.value < $1.value }
            guard let older = older else { return }
            ids[older.key] = nil
            caches[older.key] = nil
        }
    }

    func cached<Value>(id: CacheId) -> Value? {
        counters[id.counter]?[id] = Date().timeIntervalSince1970
        return caches[id] as? Value
    }

    func invalidate(type: CacheId) {
        caches[type] = nil
    }

    func invalidateAll() {
        caches = [:]
    }
}

