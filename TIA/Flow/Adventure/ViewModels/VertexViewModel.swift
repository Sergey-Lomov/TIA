//
//  VertexViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 16.04.2022.
//

import Foundation
import SwiftUI
import Combine

final class VertexViewModel: ObservableObject, IdEqutable {
    var eventsPublisher: ViewEventsPublisher

    @Published var model: Vertex
    @Published var color: Color
    @Published var elementsColor: Color

    var id: String { model.id }
    var state: VertexState { model.state }
    var point: CGPoint { model.point }

    private var subscriptions: [AnyCancellable] = []

    init(vertex: Vertex, color: Color, elementsColor: Color, eventsPublisher: ViewEventsPublisher) {
        self.model = vertex
        self.color = color
        self.elementsColor = elementsColor
        self.eventsPublisher = eventsPublisher

        subscriptions.sink(model.objectWillChange) { [weak self] in
            self?.objectWillChange.sendOnMain()
        }
    }
}

// MARK: View interaction methods
extension VertexViewModel {
    func growingFinished() {
        eventsPublisher.send(.vertexGrowingFinished(vertex: model))
    }

    func ungrowingFinished() {
        eventsPublisher.send(.vertexUngrowingFinished(vertex: model))
    }

    func wasTapped() {
        eventsPublisher.send(.vertexSelected(vertex: model))
    }
}
