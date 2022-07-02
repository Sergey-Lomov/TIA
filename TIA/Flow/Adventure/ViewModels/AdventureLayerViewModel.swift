//
//  AdventureLayerViewModel.swift
//  TIA
//
//  Created by serhii.lomov on 26.05.2022.
//

import Foundation
import Combine

final class AdventureLayerViewModel: IngameViewModel<AdventureLayer> {

    @Published var vertices: [VertexViewModel]
    @Published var edges: [EdgeViewModel]

    var state: AdventureLayerState { model.state }

    init(model: AdventureLayer, palette: ColorPalette, eventsPublisher: ViewEventsPublisher) {
        self.vertices = model.vertices.map {
            VertexViewModel(vertex: $0, color: palette.vertex, elementsColor: palette.vertexElements, eventsPublisher: eventsPublisher)
        }

        self.edges = model.edges.map {
            EdgeViewModel(model: $0, color: palette.edge, borderColor: palette.background, gateColor: palette.edge, gateSymbolColor: palette.borders, eventsPublisher: eventsPublisher)
        }

        super.init(model: model, publisher: eventsPublisher)
    }
}

// MARK: View interaction methods
extension AdventureLayerViewModel {
    func layerPrepared() {
        send(.layerPrepared(layer: model))
    }

    func layerPresented() {
        send(.layerPresented(layer: model))
    }

    func layerWasHidden() {
        send(.layerWasHidden(layer: model))
    }
}
