//
//  Edge.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation
import CoreGraphics
import SwiftUI

// In scope of phases enums elements means counter connector and gates
enum EdgeGrowingPhase: Equatable {
    case preparing
    case pathGrowing
    case waitingDestinationVertex
    case preparingElements
    case elementsGrowing
}

enum EdgeUngrowingPhase: Equatable {
    case preparing
    case elementsUngrowing
    case pathUngrowing
}

enum EdgeSeedPhase {
    case compressed
    case preextended
    case extended
}

enum EdgeState: Equatable {
    case seed(phase: EdgeSeedPhase)
    case growing(phase: EdgeGrowingPhase)
    case active
    case ungrowing(phase: EdgeUngrowingPhase)

    var isGrowed: Bool {
        switch self {
        case .seed, .growing, .ungrowing:
            return false
        case .active:
            return true
        }
    }

    var isVisible: Bool {
        switch self {
        case .seed:
            return false
        case .active, .growing, .ungrowing:
            return true
        }
    }
}

class Edge: ObservableObject, IdEqutable {
    private let curveLengthSteps: Int = 100
    private let seedCurveDelta: CGFloat = 0.1
    private let idSeparator = "|"

    var uuid = UUID().uuidString // This is unique part of vertex id
    var originId: String // This is valuable part of vertex id
    var from: Vertex
    var to: Vertex
    var gates: [EdgeGate] = []
    var growOnStart: Bool
    @Published var state: EdgeState

    // TODO: Change random seed curve to tension seed curve
    var pregrowingCurve: BezierCurve
    var curve: BezierCurve

    var id: String { originId + idSeparator + uuid }

    func length(_ geometry: GeometryProxy) -> CGFloat {
        curve.scaled(geometry).length(stepsCount: curveLengthSteps)
    }

    init(originId: String,
         from: Vertex,
         to: Vertex,
         price: [ResourceType] = [],
         growOnStart: Bool,
         state: EdgeState = .seed(phase: .compressed),
         curve: BezierCurve,
         theme: AdventureTheme) {
        self.originId = originId
        self.from = from
        self.to = to
        self.growOnStart = growOnStart
        self.state = state
        self.curve = curve

        if theme == .light {
            self.pregrowingCurve = curve
        } else {
            self.pregrowingCurve = curve.randomControlsCurve(maxDelta: seedCurveDelta)
        }

        self.gates = price.map {
            .init(requirement: .resource($0), edgeStatePublisher: $state)
        }
    }
}

extension Edge: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
