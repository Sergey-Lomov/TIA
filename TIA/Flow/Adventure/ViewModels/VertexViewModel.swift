//
//  VertexViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 16.04.2022.
//

import Foundation
import SwiftUI
import Combine

class VertexViewModel: ObservableObject {
    var eventsPublisher: ViewEventsPublisher?
    
    @Published var model: Vertex
    @Published var color: Color
    @Published var resourceColor: Color
    
    // TODO: Make all wrapped vars calculated values (no setter). Here and in all same view models
    var state: VertexState {
        get { model.state }
        set { model.state = newValue }
    }
    
    var type: VertexType {
        get { model.type }
        set { model.type = newValue }
    }
    
    var point: CGPoint {
        get { model.point }
        set { model.point = newValue }
    }
    
    private var subscriptions: [AnyCancellable] = []
    
    init(vertex: Vertex,
         color: Color,
         resourceColor: Color) {
        self.model = vertex
        self.color = color
        self.resourceColor = resourceColor
        
        subscriptions.sink(model.objectWillChange) { [weak self] in
            self?.objectWillChange.sendOnMain()
        }
    }
}

// MARK: View interaction methods
extension VertexViewModel {
    func growingFinished() {
        eventsPublisher?.send(.vertexGrowingFinished(vertex: model))
    }
    
    func wasTapped() {
        eventsPublisher?.send(.vertexSelected(vertex: model))
    }
}
