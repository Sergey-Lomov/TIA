//
//  AdventureViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 13.04.2022.
//

import Foundation
import SwiftUI
import Combine

// TODO: Investigate possibility to change provide protocol to Combine concept (provider)
protocol ViewModelsProvider: AnyObject {
    func edgeViewModel(for edge: Edge) -> EdgeViewModel?
    func vertexViewModel(for vertex: Vertex) -> VertexViewModel?
}

final class AdventureViewModel: ObservableObject, ViewEventsSource, EngineEventsListener {
    
    private var subscriptions: [AnyCancellable] = []
    var eventsPublisher = ViewEventsPublisher()
    
    var model: Adventure
    var player: PlayerViewModel
    @Published var vertices: [VertexViewModel]
    @Published var edges: [EdgeViewModel]
    @Published var resources: [ResourceViewModel]
    @Published var background: Color
    
    init(_ adventure: Adventure,
         player: Player,
         resources: [Resource],
         listener: ViewEventsListener?,
         eventsSource: EngineEventsSource?) {
        let schema = ColorSchema.schemaFor(adventure.theme)
        
        self.model = adventure
        self.player = PlayerViewModel(player: player,
                                      color: schema.player,
                                      movingColor: schema.edge)
        self.background = schema.background

        self.vertices = adventure.vertices.map {
            return VertexViewModel(vertex: $0, color: schema.vertex, resourceColor: schema.resources)
        }
        
        self.edges = adventure.edges.map {
            return EdgeViewModel(model: $0,
                                 color: schema.edge,
                                 borderColor: schema.background)
        }
        
        self.resources = resources.map {
            return ResourceViewModel(model: $0,
                                     color: schema.resources,
                                     borderColor: schema.resourcesBorder)
        }
        
        // Combine setup
        listener?.subscribeTo(eventsPublisher)
        if let source = eventsSource {
            subscribeTo(source.eventsPublisher)
        }
        vertices.forEach { $0.eventsPublisher = eventsPublisher }
        edges.forEach { $0.eventsPublisher = eventsPublisher }
        
        // Add notification about resource update, when related vertex's state update. This is necessary for valid handling resources visibility.
        for vertex in vertices {
            let subscription = vertex.model.$state.sink { _ in
                let resources = self.resourcesFor(vertex.model)
                for resource in resources {
                    resource.objectWillChange.send()
                }
            }
            subscriptions.append(subscription)
        }
        
        self.player.viewModelsProvider = self
    }
    
    // TODO: Remove if still be unsused
    func subscribeTo(_ publisher: EngineEventsPublisher) {
//        let subscription = publisher.sink {
//            [self] event in
//            handleEngineEvent(event)
//        }
//        subscriptions.append(subscription)
    }
    
    // TODO: Engine should notify view by @ObserverObject. So, this handler should be removed if it still be empty
    // MARK: Engine events handler
//    private func handleEngineEvent(_ event: EngineEvent) {
//        switch event {
//        case .playerMoves(let from, let to):
//            handlePlayersMove(from: from, to: to)
//        }
//    }
//
//    private func handlePlayersMove(from: PlayerPosition?, to: PlayerPosition?) {
//        player.position = to
//    }
    
    private func resourcesFor(_ vertex: Vertex) -> [ResourceViewModel] {
        return resources.filter {
            guard case .vertex(let inVertex, _, _) = $0.state else {
                return false
            }
            
            return inVertex.id == vertex.id
        }
    }
}

extension AdventureViewModel: ViewModelsProvider {
    func edgeViewModel(for edge: Edge) -> EdgeViewModel? {
        return edges.first { $0.model.id == edge.id }
    }
    
    func vertexViewModel(for vertex: Vertex) -> VertexViewModel? {
        return vertices.first { $0.model.id == vertex.id }
    }
}

// MARK: View interaction methods
extension AdventureViewModel {
    func viewInitCompleted() {
        eventsPublisher.send(.viewInitFinished)
    }
}
