//
//  EdgeGate.swift
//  TIA
//
//  Created by serhii.lomov on 02.05.2022.
//

import Foundation
import CoreGraphics
import Combine

enum EdgeGateState {
    case seed
    case growing
    case open   // This state means gate is open to moving cross it, so gate shoiuld be invisible
    case close  // This state means gate is closed, so gate shoiuld br presented in full size
    case ungrowing
}

enum EdgeGateRequirement {
    case resource(ResourceType)
}

typealias EdgeStatePublisher = Published<EdgeState>.Publisher

class EdgeGate: ObservableObject, IdEqutable {
    let id = UUID().uuidString
    let requirement: EdgeGateRequirement

    private var subscriptions: [AnyCancellable] = []
    @Published var state: EdgeGateState = .seed

    init(requirement: EdgeGateRequirement, edgeStatePublisher: EdgeStatePublisher) {
        self.requirement = requirement
        subscriptions.sink(edgeStatePublisher) { [weak self] state in
            DispatchQueue.main.async {
                self?.handleEdgeState(state)
            }
        }
    }

    private func handleEdgeState(_ edgeState: EdgeState) {
        switch edgeState {
        case .seed:
            state = .seed
        case .growing(let phase):
            if case .elementsGrowing = phase {
                state = .growing
            }
        case .ungrowing(let phase):
            if case .elementsUngrowing = phase {
                state = .ungrowing
            }
        case .active:
            state = .close
        }
    }
}
