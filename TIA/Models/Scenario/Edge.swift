//
//  Edge.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation
import CoreGraphics
import SwiftUI

enum EdgeGrowingPhase {
    case preparing
    case pathGrowing(duration: TimeInterval)
    case waitingDestinationVertex
    case preparingCounterConnector
    case counterConnectionGrowing(duration: TimeInterval)
}

enum EdgeSeedPhase {
    case compressed
    case preextended
    case extended
}

enum EdgeState {
    // TODO: Remove seed phases before reslease if this concept still be unused. After removing phases should be carrefully checked edge view to find unused code.
    case seed(phase: EdgeSeedPhase)
    case growing(phase: EdgeGrowingPhase)
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
    var from: Vertex
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
         state: EdgeState = .seed(phase: .compressed),
         curve: BezierCurve) {
        self.id = id
        self.from = from
        self.to = to
        self.growOnStart = growOnStart
        self.state = state
        self.curve = curve
        // TODO: For light theme seed curves should be equtable to main curves
        self.seedCurve = curve.randomControlsCurve(maxDelta: seedCurveDelta)
        self.gates = price.map { .init(requirement: .resource($0)) }
    }
}

extension Edge: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
