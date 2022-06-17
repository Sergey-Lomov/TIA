//
//  AdventureLayout.swift
//  TIA
//
//  Created by Serhii.Lomov on 12.04.2022.
//

import CoreGraphics
import Foundation
import UIKit

// TODO: If system with predefined layouts will be used at release, should be added unit tests for check scuccessfully parsing of all layouts for all adventures
final class AdventureLayout {
    typealias Controls = (p1: CGPoint, p2: CGPoint)
    
    private static let layoutsCount = 1
    
    var vertices: [String: CGPoint]
    var edges: [String: Controls]
    
    static func random(for id: String) -> AdventureLayout {
        let index = Int.random(in: 1...layoutsCount)
        let prototype = JSONDecoder.decodeLayout(adventureId: id, index: index)
        
        let vertices = prototype.vertices.reduce(into: [String: CGPoint]()) {
            $0[$1.id] = $1.point
        }
        
        let edges = prototype.edges.reduce(into: [String: Controls]()) {
            $0[$1.id] = (p1: $1.p1, p2: $1.p2)
        }
        
        return AdventureLayout(vertices: vertices, edges: edges)
    }
    
    init(vertices: [String: CGPoint], edges: [String: Controls]) {
        self.vertices = vertices
        self.edges = edges
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
    
    struct Prototype: Decodable {
        struct Vertex: Decodable {
            let id: String
            let point: CGPoint
        }
        
        struct Edge: Decodable {
            let id: String
            let p1: CGPoint
            let p2: CGPoint
        }
        
        let vertices: [Vertex]
        let edges: [Edge]
    }
}
