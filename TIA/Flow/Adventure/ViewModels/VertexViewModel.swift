//
//  VertexViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 16.04.2022.
//

import Foundation
import SwiftUI
import Combine

final class VertexViewModel: IngameViewModel<Vertex> {

    @Published var color: Color
    @Published var elementsColor: Color

    var state: VertexState { model.state }
    var point: CGPoint { model.point }

    init(vertex: Vertex, color: Color, elementsColor: Color, eventsPublisher: ViewEventsPublisher) {
        self.color = color
        self.elementsColor = elementsColor
        super.init(model: vertex, publisher: eventsPublisher)
    }
}

// MARK: View interaction methods
extension VertexViewModel {
    func growingFinished() {
        send(.vertexGrowingFinished(vertex: model))
    }

    func ungrowingFinished() {
        send(.vertexUngrowingFinished(vertex: model))
    }

    func wasTapped() {
        send(.vertexSelected(vertex: model))
    }
}
