//
//  Edge.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation
import CoreGraphics

enum EdgeState {
    case seed
    case growing(duration: TimeInterval)
    case active
    
    var isGrowed: Bool {
        switch self {
        case .seed, .growing:
            return false
        case .active:
            return true
        }
    }
}

class Edge: ObservableObject {
    private let curveLengthSteps: Int = 1000
    private let seedCurveDelta: CGFloat = 0.1
    
    let id: String
    let from: Vertex
    var to: Vertex
    var price: [Resource]
    var growOnStart: Bool
    @Published var state: EdgeState
    
    // TODO: Change random seed curve to tension seed curve
    var seedCurve: BezierCurve
    var curve: BezierCurve
    
    var length: CGFloat { curve.length(stepsCount: curveLengthSteps) }
  
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
        self.seedCurve = curve.randomControlsCurve(maxDelta: seedCurveDelta)
    }
}

extension Edge: Equatable, Hashable {
    
    static func == (lhs: Edge, rhs: Edge) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
