//
//  EdgeGateViewModel.swift
//  TIA
//
//  Created by serhii.lomov on 01.07.2022.
//

import SwiftUI
import Combine

final class EdgeGateViewModel: IngameViewModel<EdgeGate> {

    @Published var color: Color
    @Published var symbolColor: Color

    var state: EdgeGateState { model.state }

    init(model: EdgeGate, color: Color, symbolColor: Color, eventsPublisher: ViewEventsPublisher) {
        self.color = color
        self.symbolColor = symbolColor
        super.init(model: model, publisher: eventsPublisher)
    }
}

// MARK: View interaction methods
extension EdgeGateViewModel {
    func closingFinished() {
        send(.gateClosed(gate: model))
    }
}
