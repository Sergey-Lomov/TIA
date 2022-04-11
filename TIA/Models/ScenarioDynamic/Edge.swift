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
    let from: Vertex?
    var to: Vertex?
    var price: [Resource] = []
    var growOnStart: Bool
    var state: EdgeState = .seed
    
    init(prototype: EdgePrototype, vertices: [Vertex]) {
        from = vertices.first { $0.id == prototype.from.id }
        to = vertices.first { $0.id == prototype.to.id }
        price = prototype.price
        growOnStart = prototype.growOnStart
    }
}
