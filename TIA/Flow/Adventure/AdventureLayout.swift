//
//  AdventureLayout.swift
//  TIA
//
//  Created by Serhii.Lomov on 12.04.2022.
//

import CoreGraphics
import Foundation

// TODO: If system with predefined layouts will be used at release, should be added unit tests for check scuccessfully parsing of all layouts for all adventures
class AdventureLayout {
    private let layoutsCount = 1
    
    let vertices: [String: CGPoint]
    let edges: [String: BezierCurve]
    
    init(randomFor adventure: Adventure) {
        let index = Int.random(in: 1...layoutsCount)
        let prototype = JSONDecoder().decodeLayout(adventureId: adventure.id, index: index)
        
        let vertices = prototype.vertices.reduce(into: [String: CGPoint]()) {
            $0[$1.id] = $1.point
        }
        
        let edges = prototype.edges.reduce(into: [String: BezierCurve]()) {
            guard let edge = adventure.edges.firstById($1.id) else {
                fatalError("Invalid edge id \"\($1.id)\" in layout \(adventure.id):\(index)")
            }
            
            guard let from = vertices[edge.from.id],
                  let to = vertices[edge.to.id] else {
                fatalError("Missed vertices connected to edge \"\($1.id)\" in layout \(adventure.id):\(index)")
            }
            
            $0[$1.id] = BezierCurve(from: from,
                                    to: to,
                                    control1: $1.p1,
                                    control2: $1.p2)
        }
        
        self.vertices = vertices
        self.edges = edges
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
