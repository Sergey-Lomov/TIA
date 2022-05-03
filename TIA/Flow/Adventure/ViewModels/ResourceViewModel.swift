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
    
    var id: String { model.id }
    var model: Resource
    @Published var color: Color
    @Published var borderColor: Color
    
    private var subscriptions: [AnyCancellable] = []
    var eventsPublisher: ViewEventsPublisher?
    
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
        
        subscriptions.sink(model.objectWillChange) { [weak self] in
            self?.objectWillChange.send()
        }
    }
}

// MARK: View interaction methods
extension ResourceViewModel {
    func moveToGateFinished() {
        guard case .gate(let gate, _, _, _) = model.state else { return }
        eventsPublisher?.send(.resourceMovedToGate(gate: gate))
    }
}

