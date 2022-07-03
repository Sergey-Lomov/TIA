//
//  CachingService.swift
//  TIA
//
//  Created by serhii.lomov on 03.07.2022.
//

import Foundation
import Accessibility

enum CacheType: Hashable {
    case layerCamera(_ layer: AdventureLayer)
    case failNearGate(_ gate: EdgeGate, _ vertex: Vertex)
    case curveLength(_ points: [CGPoint])
    case surrounding(_ vertex: Vertex, _ layer: AdventureLayer)
}

// TODO: Implement cashing limit for prevent infinity cash extending. Limit should calculates differently for each cash type
final class CachService {
    static var shared = CachService()

    private var caches: [CacheType: Any] = [:]

    func cach(type: CacheType, value: Any) {
        if caches[type] == nil {
            caches[type] = [:]
        }
        caches[type] = value
    }

    func cached<Value>(type: CacheType) -> Value? {
        caches[type] as? Value
    }

    func invalidate(type: CacheType) {
        caches[type] = nil
    }
}

