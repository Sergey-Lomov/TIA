//
//  AdventureLayout.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 10.07.2022.
//

import Foundation

extension AdventureLayout {
    static func autolayout(for adventure: AdventurePrototype) -> AdventureLayout {
        let yGap = 0.05
        var vertices = [String: CGPoint]()
        for i in 0..<adventure.vertices.count {
            let y = (1.0 - yGap * 2) / CGFloat(adventure.vertices.count) * CGFloat(i) + yGap - 0.5
            vertices[adventure.vertices[i].id] = CGPoint(x: 0, y: y)
        }

        var edges = [String: Controls]()
        for i in 0..<adventure.edges.count {
            let edge = adventure.edges[i]
            let p1 = vertices[edge.from] ?? .zero
            let p2 = vertices[edge.to] ?? .zero
            edges[edge.id] = Controls(p1, p2)
        }
        return AdventureLayout(vertices: vertices, edges: edges)
    }
}
