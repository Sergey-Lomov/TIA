//
//  AdventureLayerViewModel.swift
//  TIA
//
//  Created by serhii.lomov on 26.05.2022.
//

import Foundation
import Combine

final class AdventureLayerViewModel: ObservableObject, IdEqutable {
    private var subscriptions: [AnyCancellable] = []
    var eventsPublisher: ViewEventsPublisher

    var model: AdventureLayer
    @Published var vertices: [VertexViewModel]
    @Published var edges: [EdgeViewModel]

    var id: String { model.id }
    var state: AdventureLayerState { model.state }

    init(model: AdventureLayer, palette: ColorPalette, eventsPublisher: ViewEventsPublisher) {
        self.model = model
        self.eventsPublisher = eventsPublisher

        self.vertices = model.vertices.map {
            VertexViewModel(vertex: $0, color: palette.vertex, elementsColor: palette.vertexElements, eventsPublisher: eventsPublisher)
        }

        self.edges = model.edges.map {
            EdgeViewModel(model: $0, color: palette.edge, borderColor: palette.background, gateColor: palette.edge, gateSymbolColor: palette.borders, eventsPublisher: eventsPublisher)
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
