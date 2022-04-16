//
//  Edge.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation

enum EdgeState {
    case seed
    case growing(duration: TimeInterval)
    case active
}

class Edge: ObservableObject {
    let id: String
    let from: Vertex
    var to: Vertex
    var price: [Resource]
    var growOnStart: Bool
    @Published var state: EdgeState
    var curve: BezierCurve
  
    init(id: String,
         from: Vertex,
         to: Vertex,
         price: [Resource] = [],
         growOnStart: Bool,
         state: EdgeState = .seed,
         curve: BezierCurve) {
        self.id = id
        self.from = from
        self.to = to
        self.price = price
        self.growOnStart = growOnStart
        self.state = state
        self.curve = curve
    }
}
