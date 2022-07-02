//
//  AdventureIconViewModel.swift
//  TIA
//
//  Created by serhii.lomov on 27.06.2022.
//

import SwiftUI
import Combine

enum AdventureIconState: Equatable {
    case planed
    case becameCurrent
    case current
    case opening
    case preclosing
    case closing(willBeDone: Bool)
    case becameDone(slot: Int)
    case done(slot: Int)
}

final class AdventureIconViewModel: BaseViewModel<AdventureDescriptor> {

    @Published var state: AdventureIconState

    init(model: AdventureDescriptor, state: AdventureIconState) {
        self.state = state
        super.init(model: model)
    }

    func animationCompleted() {
        switch state {
        case .becameCurrent:
            state = .current
        case .becameDone(let slot):
            state = .done(slot: slot)
        default:
            break
        }
    }
}
