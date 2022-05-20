//
//  Adventure.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation

enum AdventureTheme: String, Codable, CaseIterable {
    case dark
    case light
    case truth
}

enum AdventureState {
    case done
    case current
    case planed
}

class Adventure: ObservableObject {
    
    private static let menuEdgePrefix = "menu_edge_"

    let id: String
    let index: Int
    var theme: AdventureTheme
    var vertices: [Vertex]
    var edges: [Edge]
    
    @Published var state: AdventureState = .planed
    
    var entrances: [Vertex] {
        vertices.filter { $0.type == .entrance }
    }
    
    init(id: String,
         index: Int,
         theme: AdventureTheme,
         vertices: [Vertex],
         edges: [Edge]) {
        self.id = id
        self.index = index
        self.theme = theme
        self.vertices = vertices
        self.edges = edges
    }
    
    func menuEdge(from: Vertex) -> Edge? {
        return edges.firstById(Self.menuEdgePrefix + from.id)
    }
    
    func addMenuEdge(from: Vertex, to: Vertex, curve: BezierCurve) -> Edge {
        let edge = Edge(id: Self.menuEdgePrefix + from.id, from: from, to: to, growOnStart: false, curve: curve)
        edges.append(edge)
        return edge
    }
    
    func removeMenuEdge(from: Vertex) -> Edge? {
        let edge = edges.first { $0.id == Self.menuEdgePrefix + from.id }
        guard let edge = edge else { return nil }
        edges.remove(edge)
        return edge
    }
}
