//
//  AdventureViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 13.04.2022.
//

import Foundation
import SwiftUI
import Combine

final class AdventureViewModel: ObservableObject, ViewEventsSource, EngineEventsListener {
    
    private var subscriptions: [AnyCancellable] = []
    var eventsPublisher = ViewEventsPublisher()
    
    var model: Adventure
    var player: PlayerViewModel
    @Published var vertices: [VertexViewModel]
    @Published var edges: [EdgeViewModel]
    
    init(_ adventure: Adventure, listener: ViewEventsListener?, eventsSource: EngineEventsSource?) {
        self.model = adventure
        self.player = PlayerViewModel()

        let vertexColor = Color.inversedFor(adventure.theme)
        self.vertices = adventure.vertices.map {
            return VertexViewModel(vertex: $0,
                                   isCurrent: false,
                                   color: vertexColor)
        }
        
        let edgeColor = Color.inversedFor(adventure.theme)
        let borderColor = Color.mainFor(adventure.theme)
        self.edges = adventure.edges.map {
            return EdgeViewModel(model: $0,
                                 color: edgeColor,
                                 borderColor: borderColor)
        }
        
        // Combine setup
        listener?.subscribeTo(eventsPublisher)
        if let source = eventsSource {
            subscribeTo(source.eventsPublisher)
        }
        vertices.forEach { $0.eventsPublisher = eventsPublisher }
        edges.forEach { $0.eventsPublisher = eventsPublisher }
    }
    
    func subscribeTo(_ publisher: EngineEventsPublisher) {
        let subscription = publisher.sink {
            [self] event in
            handleEngineEvent(event)
        }
        subscriptions.append(subscription)
    }
    
    private func handleEngineEvent(_ event: EngineEvent) {
        switch event {
        case .playerMoves(let from, let to):
            handlePlayersMove(from: from, to: to)
        }
    }
    
    // MARK: Engine events handler
    private func handlePlayersMove(from: PlayerPosition?, to: PlayerPosition?) {
        player.position = to
    }
}

// MARK: View interaction methods
extension AdventureViewModel {
    func viewInitCompleted() {
        eventsPublisher.send(.viewInitFinished)
    }
}
