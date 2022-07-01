//
//  EyeViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 22.04.2022.
//

import Foundation

// TODO: many code inside this view model related to handle complex eye animation with few possbile states and transition between it. Very possible same kind of logic will be useful. In this case solution should be implemented like a separate system (state-machine)

enum EyeState: Int {
    case compressed
    case closed
    case opened

    var isOpen: Bool {
        switch self {
        case .opened:
            return true
        default:
            return false
        }
    }
}

enum EyeStatus {
    case state(EyeState)
    case transiotion(from: EyeState, to: EyeState)

    var targetState: EyeState {
        switch self {
        case .state(let eyeState):
            return eyeState
        case .transiotion(_, let to):
            return to
        }
    }
}

final class EyeViewModel: ObservableObject {
    @Published var status: EyeStatus
    private(set) var targetState: EyeState?

    init() {
        self.status = .state(.compressed)
        self.targetState = nil
    }

    func open() { setState(.opened) }
    func close() { setState(.closed) }
    func compress() { setState(.compressed) }

    private func setState(_ state: EyeState) {
        if case .state(state) = status { return }
        targetState = state
        startTransition()
    }

    func transitionFinished() {
        guard case .transiotion(_, let to) = status else {
            return
        }

        status = .state(to)
        if targetState != to {
            startTransition()
        }
    }

    private func startTransition() {
        guard case .state(let state) = status,
            let target = targetState else {
            return
        }

        if state == target { return }
        let modifier = state.rawValue > target.rawValue ? -1 : 1
        let to = EyeState(rawValue: state.rawValue + modifier) ?? target
        status = .transiotion(from: state, to: to)
    }
}
