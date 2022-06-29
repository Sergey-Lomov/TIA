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
    case closing
    case becameDone(slot: Int)
    case done(slot: Int)
}

// TODO: Check all view models is final. Investigate other case, where final may be actual (services?). Try to setup SwiftLint.
final class AdventureIconViewModel: ObservableObject, IdEqutable {
    private var subscriptions: [AnyCancellable] = []
    
    var adventure: AdventureDescriptor
    @Published var state: AdventureIconState
    
    var id: String { adventure.id }
    
    init(adventure: AdventureDescriptor, state: AdventureIconState) {
        self.adventure = adventure
        self.state = state
        
        // TODO: Move this common case to custom property wrapper Transpublished
        subscriptions.sink(adventure.objectWillChange) { [weak self] in
            self?.objectWillChange.sendOnMain()
        }
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
