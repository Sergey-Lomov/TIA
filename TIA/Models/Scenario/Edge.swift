//
//  Edge.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation
import CoreGraphics
import SwiftUI

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

class Edge: ObservableObject, IdEqutable {
    private let curveLengthSteps: Int = 100
    private let seedCurveDelta: CGFloat = 0.1
    
    let id: String
    let from: Vertex
    var to: Vertex
    var gates: [EdgeGate]
    var growOnStart: Bool
    @Published var state: EdgeState
    
    // TODO: Change random seed curve to tension seed curve
    var seedCurve: BezierCurve
    var curve: BezierCurve
    
    // TODO: This method should be removed at further refactoring, because unscaled curve get no valid results (uses square coordinates insted of rectangle)
    func length() -> CGFloat {
        curve.length(stepsCount: curveLengthSteps)
    }
    
    func length(_ geometry: GeometryProxy) -> CGFloat {
        curve.scaled(geometry).length(stepsCount: curveLengthSteps)
    }
  
    init(id: String,
         from: Vertex,
         to: Vertex,
         price: [ResourceType] = [],
         growOnStart: Bool,
         state: EdgeState = .seed,
         curve: BezierCurve) {
        self.id = id
        self.from = from
        self.to = to
        self.growOnStart = growOnStart
        self.state = state
        self.curve = curve
        self.seedCurve = curve.randomControlsCurve(maxDelta: seedCurveDelta)
        self.gates = price.map { .init(requirement: .resource($0)) }
//        self.gates = []
//
//        for resource in price {
//            let ratio = CGFloat(gates.count + 1) / CGFloat(price.count)
//            let point = curve.getPoint(lengthRatio: ratio, steps: 100)
//            let gate = EdgeGate(point: point, requirement: .resource(resource))
//            gates.append(gate)
//        }
    }
}

extension Edge: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
