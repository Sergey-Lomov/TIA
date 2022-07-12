//
//  AdventureLayout.swift
//  TIA
//
//  Created by Serhii.Lomov on 12.04.2022.
//

import CoreGraphics
import Foundation

final class AdventureLayout {
    typealias Controls = (p1: CGPoint, p2: CGPoint)

    var vertices: [String: CGPoint]
    var edges: [String: Controls]

    init(vertices: [String: CGPoint], edges: [String: Controls]) {
        self.vertices = vertices
        self.edges = edges
    }

    convenience init(_ prototype: AdventureLayoutPrototype) {
        let vertices = prototype.vertices.reduce(into: [String: CGPoint]()) {
            $0[$1.id] = $1.point
        }

        let edges = prototype.edges.reduce(into: [String: Controls]()) {
            $0[$1.id] = (p1: $1.p1, p2: $1.p2)
        }

        self.init(vertices: vertices, edges: edges)
    }

    func translate(by delta: CGPoint) {
        for id in vertices.keys {
            vertices[id] = vertices[id]?.translated(by: delta)
        }
        for id in edges.keys {
            guard let p1 = edges[id]?.p1, let p2 = edges[id]?.p2 else {
                continue
            }
            edges[id] = (p1.translated(by: delta), p2.translated(by: delta))
        }
    }
}
