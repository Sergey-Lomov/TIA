//
//  EdgeViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 16.04.2022.
//

import Foundation
import SwiftUI
import Combine

class EdgeViewModel: ObservableObject, IdEqutable {

    var model: Edge
    var gates: [EdgeGateViewModel]
    @Published var color: Color
    @Published var borderColor: Color
    
    private var subscriptions: [AnyCancellable] = []
    var eventsPublisher: ViewEventsPublisher
    
    var id: String { model.id }
    var curve: BezierCurve { model.curve }
    var state: EdgeState { model.state }
    
    init(model: Edge, color: Color, borderColor: Color, gateColor: Color, gateSymbolColor: Color, eventsPublisher: ViewEventsPublisher) {
        self.model = model
        self.color = color
        self.borderColor = borderColor
        self.eventsPublisher = eventsPublisher
        
        self.gates = model.gates.map {
            EdgeGateViewModel(model: $0, color: gateColor, symbolColor: gateSymbolColor, eventsPublisher: eventsPublisher)
        }
        
        subscriptions.sink(model.objectWillChange) { [weak self] in
            self?.objectWillChange.sendOnMain()
        }
    }
}

// MARK: View interaction methods
extension EdgeViewModel {
    
    func seedExtensionPrepared() {
        eventsPublisher.send(.edgeSeedExtensionPrepared(edge: model))
    }
    
    func growingPrepared() {
        eventsPublisher.send(.edgeGrowingPrepared(edge: model))
    }
    
    func pathGrowingFinished() {
        eventsPublisher.send(.edgePathGrowed(edge: model))
    }
    
    func elementsGrowingPrepared() {
        eventsPublisher.send(.edgeElementsPrepared(edge: model))
    }
    
    func elementsGrowingFinished() {
        eventsPublisher.send(.edgeElementsGrowed(edge: model))
    }
    
    func ungrowingPrepared() {
        eventsPublisher.send(.edgeUngrowingPrepared(edge: model))
    }
    
    func elementsUngrowed() {
        eventsPublisher.send(.edgeElementsUngrowed(edge: model))
    }
    
    func ungrowingFinished() {
        eventsPublisher.send(.edgeUngrowed(edge: model))
    }
}
