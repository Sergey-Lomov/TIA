//
//  ResourceViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 26.04.2022.
//

import Foundation
import SwiftUI
import Combine

class ResourceViewModel: ObservableObject, IdEqutable {
    
    var model: Resource
    var positioningStep: CGFloat = 0
    @Published var color: Color
    @Published var borderColor: Color
    
    private var subscriptions: [AnyCancellable] = []
    var eventsPublisher: ViewEventsPublisher?
    
    var id: String { model.id }
    var type: ResourceType {
        get { model.type }
        set { model.type = newValue }
    }
    
    var state: ResourceState {
        get { model.state }
        set { model.state = newValue }
    }
    
    init(model: Resource, color: Color, borderColor: Color) {
        self.model = model
        self.color = color
        self.borderColor = borderColor
        
        subscriptions.sink(model.$state) { [weak self] state in
            if !model.state.animationIntermediate {
                self?.positioningStep += 1
            }
        }
        
        subscriptions.sink(model.objectWillChange) { [weak self] in
            self?.objectWillChange.sendOnMain()
        }
    }
}

// MARK: View interaction methods
extension ResourceViewModel {
    func presentationFinished() {
        eventsPublisher?.send(.resourcePresented(resource: model))
    }
    
    func idleFinished() {
        eventsPublisher?.send(.resourceIdleFinished(resource: model))
    }
    
    func idleRestoringFinished() {
        eventsPublisher?.send(.resourceIdleRestored(resource: model))
    }
    
    func moveToGateFinished() {
        eventsPublisher?.send(.resourceMovedToGate(resource: model))
    }
    
    func moveFromGateFinished() {
        guard case .gate(_, _, _, _, _, let prestate) = model.state else { return }
        model.state = prestate
    }
    
    func moveNearGateFinished() {
        switch metastate {
        case .failedNear(let gate, _, let vertex, _, _):
            GeometryCacheService.shared.invalidateFailNearGate(gate: gate, vertex: vertex)
        default:
            break
        }
    }
}
