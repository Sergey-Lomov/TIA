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
       
        self.vertices.forEach { $0.eventsPublisher = eventsPublisher }
        self.edges.forEach { $0.eventsPublisher = eventsPublisher }
        self.resources.forEach { resource in
            resource.eventsPublisher = eventsPublisher
            self.subscriptions.sink(resource.model.$state) { [weak self] newState in
                self?.resource(resource, willChangeState: newState)
            }
        }
        
        // Add notification about resource update, when related vertex's state update. This is necessary for valid handling resources visibility.
        // TODO: Same things should be done in scope of Adventure Engine
        for vertex in vertices {
            subscriptions.sink(vertex.model.$state) {
                let resources = self.resourcesFor(vertex.model)
                for resource in resources {
                    resource.objectWillChange.sendOnMain()
                }
            }
        }
        
        self.player.viewModelsProvider = self
    }
    
    private func resource(_ resource: ResourceViewModel, willChangeState state: ResourceState) {
        switch state {
        case .deletion:
            resources.remove(resource)
        default:
            break
        }
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
    
    // TODO: This method may became unused after done another TODOs in this file
    private func resourcesFor(_ vertex: Vertex) -> [ResourceViewModel] {
        return resources.filter {
            guard case .vertex(let inVertex, _, _, _) = $0.state else {
                return false
            }
            
            return inVertex == vertex
        }
    }
}

extension AdventureViewModel: ViewModelsProvider {
    func edgeViewModel(for edge: Edge) -> EdgeViewModel? {
        return edges.first { $0.model == edge }
    }
    
    func vertexViewModel(for vertex: Vertex) -> VertexViewModel? {
        return vertices.first { $0.model == vertex }
    }
}

// MARK: View interaction methods
extension AdventureViewModel {
    func viewInitCompleted() {
        eventsPublisher.send(.viewInitFinished)
    }
}
