//
//  ResourceViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 26.04.2022.
//

import Foundation
import SwiftUI
import Combine

// For resources implemented reusable view models solution. In general, this solution is same with reusable table view cells. This is required to prevent unnecessary UI update of all resources at one resource removing.
class ResourceViewModel: ObservableObject, IdEqutable {
    
    var viewId = UUID().uuidString
    var model: Resource?
    var positioningStep: CGFloat = 0
    @Published var color: Color
    @Published var borderColor: Color
    
    private var subscriptions: [AnyCancellable] = []
    var eventsPublisher: ViewEventsPublisher?
    
    var id: String { viewId }
    var type: ResourceType? { model?.type }
    var state: ResourceState? { model?.state }
    var isEmpty: Bool { model == nil }
    
    init(model: Resource, color: Color, borderColor: Color) {
        self.model = model
        self.color = color
        self.borderColor = borderColor
        setupSubscriptions()
    }
    
    func attachModel(_ model: Resource, color: Color, borderColor: Color) {
        self.model = model
        self.setupSubscriptions()
        DispatchQueue.main.async {
            self.color = color
            self.borderColor = borderColor
        }
    }
    
    func detachModel() {
        model = nil
        subscriptions.removeAll()
    }
    
    private func setupSubscriptions() {
        guard let model = model else { return }
        
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
        guard let model = model else { return }
        eventsPublisher?.send(.resourcePresented(resource: model))
    }
    
    func idleFinished() {
        guard let model = model else { return }
        eventsPublisher?.send(.resourceIdleFinished(resource: model))
    }
    
    func idleRestoringFinished() {
        guard let model = model else { return }
        eventsPublisher?.send(.resourceIdleRestored(resource: model))
    }
    
    func moveToGateFinished() {
        guard let model = model else { return }
        eventsPublisher?.send(.resourceMovedToGate(resource: model))
    }
    
    func moveFromGateFinished() {
        guard let model = model else { return }
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
    
    func resourceDestroyingPrepared() {
        guard let model = model else { return }
        eventsPublisher?.send(.resourceDestroyingPrepared(resource: model))
    }
    
    func destoryingFinished() {
        guard let model = model else { return }
        eventsPublisher?.send(.resourceDestroyed(resource: model))
    }
}
