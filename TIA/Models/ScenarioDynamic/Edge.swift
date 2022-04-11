//
//  Edge.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation

enum EdgeState {
    case seed
    case active
}

class Edge {
    let from: Vertex
    var to: Vertex
    var price: [Resource] = []
    var growOnStart: Bool
    var state: EdgeState = .seed
    
    init(prototype: EdgePrototype, vertices: [Vertex]) throws {
        let fromId = prototype.from.id
        guard let fromVertex = vertices.firstById(fromId) else {
            throw TIAPrototypingError.missedVertex(id: fromId)
        }
        from = fromVertex
        
        let toId = prototype.to.id
        guard let toVertex = vertices.firstById(toId) else {
            throw TIAPrototypingError.missedVertex(id: toId)
        }
        to = toVertex
        
        price = prototype.price
        growOnStart = prototype.growOnStart
    }
}
