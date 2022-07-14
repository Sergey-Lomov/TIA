//
//  EdgeViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 16.04.2022.
//

import Foundation
import SwiftUI
import Combine

final class EdgeViewModel: IngameViewModel<Edge> {

    var gates: [EdgeGateViewModel]
    var prechangeCurve: BezierCurve?

    @Published var color: Color
    @Published var borderColor: Color
    @Published var isEditing: Bool = false

    var curve: BezierCurve { model.curve }
    var state: EdgeState { model.state }

    init(model: Edge, color: Color, borderColor: Color, gateColor: Color, gateSymbolColor: Color, eventsPublisher: ViewEventsPublisher) {
        self.color = color
        self.borderColor = borderColor

        self.gates = model.gates.map {
            EdgeGateViewModel(model: $0, color: gateColor, symbolColor: gateSymbolColor, eventsPublisher: eventsPublisher)
        }

        super.init(model: model, publisher: eventsPublisher)
    }
}

// MARK: View interaction methods
extension EdgeViewModel {

    func seedExtensionPrepared() {
        send(.edgeSeedExtensionPrepared(edge: model))
    }

    func growingPrepared() {
        send(.edgeGrowingPrepared(edge: model))
    }

    func pathGrowingFinished() {
        send(.edgePathGrowed(edge: model))
    }

    func elementsGrowingPrepared() {
        send(.edgeElementsPrepared(edge: model))
    }

    func elementsGrowingFinished() {
        send(.edgeElementsGrowed(edge: model))
    }

    func ungrowingPrepared() {
        send(.edgeUngrowingPrepared(edge: model))
    }

    func elementsUngrowed() {
        send(.edgeElementsUngrowed(edge: model))
    }

    func ungrowingFinished() {
        send(.edgeUngrowed(edge: model))
    }

    func controlChanged(point: ControlPoint, newValue: CGPoint) {
        prechangeCurve = prechangeCurve ?? model.curve
        send(.edgeControlChanged(edge: model, point: point, newValue: newValue, finished: false))
    }

    func controlChangingFinished(point: ControlPoint, newValue: CGPoint) {
        prechangeCurve = nil
        send(.edgeControlChanged(edge: model, point: point, newValue: newValue, finished: true))
    }
}
