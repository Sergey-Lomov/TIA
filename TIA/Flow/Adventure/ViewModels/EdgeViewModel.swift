//
//  EdgeViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 16.04.2022.
//

import Foundation
import SwiftUI
import Combine

class EdgeViewModel: ObservableObject {
    
    var model: Edge
    @Published var color: Color
    @Published var borderColor: Color
    
    private var subscriptions: [AnyCancellable] = []
    var eventsPublisher: ViewEventsPublisher?
    
    var curve: BezierCurve { model.curve }
    var state: EdgeState { model.state }
    
    init(model: Edge,
         color: Color,
         borderColor: Color) {
        self.model = model
        self.color = color
        self.borderColor = borderColor
        
        subscriptions.sink(model.objectWillChange) { [weak self] in
            self?.objectWillChange.sendOnMain()
        }
    }
}

// MARK: View interaction methods
extension EdgeViewModel {
    
    func seedExtensionPrepared() {
        eventsPublisher?.send(.edgeSeedExtensionPrepared(edge: model))
    }
    
    func growingPrepared() {
        eventsPublisher?.send(.edgeGrowingPrepared(edge: model))
    }
    
    func pathGrowingFinished() {
        eventsPublisher?.send(.edgePathGrowed(edge: model))
    }
    
    func counterConnectorGrowingPrepared() {
        eventsPublisher?.send(.edgeCounterConnectorPrepared(edge: model))
    }
    
    func counterConnectorGrowingFinished() {
        eventsPublisher?.send(.edgeCounterConnectorGrowed(edge: model))
    }
}
