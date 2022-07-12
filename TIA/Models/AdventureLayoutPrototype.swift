//
//  AdventureLayoutPrototype.swift
//  TIA
//
//  Created by serhii.lomov on 12.07.2022.
//

import Foundation

struct AdventureLayoutPrototype: Codable {
    struct Vertex: Codable {
        let id: String
        let point: CGPoint
    }

    struct Edge: Codable {
        let id: String
        let p1: CGPoint
        let p2: CGPoint
    }

    let vertices: [Vertex]
    let edges: [Edge]

    init(vertices: [Vertex], edges: [Edge]) {
        self.vertices = vertices
        self.edges = edges
    }

    init(_ layout: AdventureLayout) {
        self.vertices = layout.vertices.map {
            Vertex(id: $0.key, point: $0.value)
        }

        self.edges = layout.edges.map {
            Edge(id: $0.key, p1: $0.value.p1, p2: $0.value.p2)
        }
    }
}
