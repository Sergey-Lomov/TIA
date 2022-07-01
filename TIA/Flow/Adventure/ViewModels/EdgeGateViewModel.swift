//
//  EdgeGateViewModel.swift
//  TIA
//
//  Created by serhii.lomov on 01.07.2022.
//

import SwiftUI
import Combine

class EdgeGateViewModel: ObservableObject, IdEqutable {

    var model: EdgeGate
    @Published var color: Color
    @Published var symbolColor: Color

    private var subscriptions: [AnyCancellable] = []
    var eventsPublisher: ViewEventsPublisher

    var id: String { model.id }
    var state: EdgeGateState { model.state }

    init(model: EdgeGate, color: Color, symbolColor: Color, eventsPublisher: ViewEventsPublisher) {
        self.model = model
        self.color = color
        self.symbolColor = symbolColor
        self.eventsPublisher = eventsPublisher

        subscriptions.sink(model.objectWillChange) { [weak self] in
            self?.objectWillChange.sendOnMain()
        }
    }
}

// MARK: View interaction methods
extension EdgeGateViewModel {
    func closingFinished() {
        eventsPublisher.send(.gateClosed(gate: model))
    }
}
