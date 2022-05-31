//
//  AdventureLayerViewModel.swift
//  TIA
//
//  Created by serhii.lomov on 26.05.2022.
//

import Foundation
import Combine

class AdventureLayerViewModel: ObservableObject {
    private var subscriptions: [AnyCancellable] = []
    var eventsPublisher: ViewEventsPublisher
    
    var model: AdventureLayer
    @Published var vertices: [VertexViewModel]
    @Published var edges: [EdgeViewModel]

    var id: String { model.id }
    var state: AdventureLayerState { model.state }
    
    init(model: AdventureLayer, schema: ColorSchema, eventsPublisher: ViewEventsPublisher) {
        self.model = model
        self.eventsPublisher = eventsPublisher
        
        self.vertices = model.vertices.map {
            VertexViewModel(vertex: $0, color: schema.vertex, resourceColor: schema.resources, eventsPublisher: eventsPublisher)
        }
        
        self.edges = model.edges.map {
            EdgeViewModel(model: $0, color: schema.edge, borderColor: schema.background, eventsPublisher: eventsPublisher)
        }
        
        subscriptions.sink(model.objectWillChange) { [weak self] in
            self?.objectWillChange.sendOnMain()
        }
    }
}

// MARK: View interaction methods
extension AdventureLayerViewModel {
    func layerPrepared() {
        eventsPublisher.send(.layerPrepared(layer: model))
    }
    
    func layerPresented() {
        eventsPublisher.send(.layerPresented(layer: model))
    }
    
    func layerWasHidden() {
        eventsPublisher.send(.layerWasHidden(layer: model))
    }
}
