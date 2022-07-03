//
//  AdventureLayer.swift
//  TIA
//
//  Created by serhii.lomov on 26.05.2022.
//

import Foundation

enum AdventureLayerType {
    case initial
    case additional
    case menu
}

enum AdventureLayerState: Equatable {
    case preparing
    case presenting
    case growing
    case shown
    case ungrowing(exit: Vertex?)
    case hiding(next: AdventureLayer?)

    #if DEBUG
    var short: String {
        switch self {
        case .preparing:
            return "p"
        case .presenting:
            return "r"
        case .growing:
            return "g"
        case .shown:
            return "s"
        case .hiding:
            return "h"
        case .ungrowing:
            return "u"
        }
    }
    #endif
}

class AdventureLayer: ObservableObject, IdEqutable {
    let id: String = UUID().uuidString
    let type: AdventureLayerType
    @Published var state: AdventureLayerState
    var vertices: [Vertex]
    var edges: [Edge]
    var entrance: Vertex

    init(type: AdventureLayerType, state: AdventureLayerState, vertices: [Vertex], edges: [Edge], entrance: Vertex) {
        self.type = type
        self.state = state
        self.vertices = vertices
        self.edges = edges
        self.entrance = entrance
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func outcome(_ vertex: Vertex) -> [Edge] {
        return edges.filter { $0.from == vertex }
    }

    func income(_ vertex: Vertex) -> [Edge] {
        return edges.filter { $0.to == vertex }
    }

    func edges(of vertex: Vertex) -> [Edge] {
        var edges = outcome(vertex)
        edges.append(contentsOf: income(vertex))
        return Array(Set(edges))
    }

    func edgesBetween(v1: Vertex, v2: Vertex) -> [Edge] {
        edges.filter { ($0.from == v1 && $0.to == v2) || ($0.to == v1 && $0.from == v2) }
    }

    func isInitialGrowingFinished() -> Bool {
        switch state {
        case .preparing, .presenting: return false
        case .shown, .hiding, .ungrowing: return true
        case .growing: return calculateInitialGrowing()
        }
    }

    private func calculateInitialGrowing() -> Bool {
        let growingChecker: (Edge) -> Bool = { edge in
            edge.state.isGrowed && edge.from.state.isGrowed && edge.to.state.isGrowed
        }
        return !edges.contains { $0.growOnStart && !growingChecker($0)}
    }

    func contains(_ vertex: Vertex) -> Bool {
        vertices.contains(vertex)
    }

    func contains(_ edge: Edge) -> Bool {
        edges.contains(edge)
    }
}

extension Array where Element == AdventureLayer {
    func allContain(_ edge: Edge) -> [AdventureLayer] {
        filter { $0.contains(edge) }
    }

    func allContain(_ vertex: Vertex) -> [AdventureLayer] {
        filter { $0.contains(vertex) }
    }
}
