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
    let id: String
    let from: Vertex
    var to: Vertex
    var price: [Resource]
    var growOnStart: Bool
    var state: EdgeState
  
    init(id: String,
         from: Vertex,
         to: Vertex,
         price: [Resource] = [],
         growOnStart: Bool,
         state: EdgeState = .seed) {
        self.id = id
        self.from = from
        self.to = to
        self.price = price
        self.growOnStart = growOnStart
        self.state = state
    }
}
