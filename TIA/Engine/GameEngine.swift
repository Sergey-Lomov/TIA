//
//  GameEngine.swift
//  TIA
//
//  Created by Serhii.Lomov on 15.04.2022.
//

import Foundation
import CoreGraphics
import Combine

final class GameEngine {

    static let shared = GameEngine(state: GameState())

    private var subscriptions: [AnyCancellable] = []

    let state: GameState
    var adventureEngine: AdventureEngine?

    init(state: GameState) {
        self.state = state
    }

    func startAdventure(_ descriptor: AdventureDescriptor) {
        let prototype = JSONDecoder.decodeAdventure(id: descriptor.id)
        state.activeAdventure = prototype
        let engine = AdventureEngine(prototype: prototype, layoutProvider: self, menuItems: availableIngameMenuItems())
        subscribeTo(engine.eventsPublisher)
        adventureEngine = engine
    }

    func availableIngameMenuItems() -> [IngameMenuItem] {
        return [.exit, .restart]
    }
}

extension GameEngine: AdventureLayoutProvider {
    private static let layoutsCount: [String: Int] = [
        "dark1": 4,
    ]

    func getLayout(_ adventure: AdventurePrototype) -> AdventureLayout {
        let count = Self.layoutsCount[adventure.id] ?? 1
        let index = Int.random(in: 1...count)
        let protoLayout = JSONDecoder.decodeLayout(adventureId: adventure.id, index: index)
        return AdventureLayout(protoLayout)
    }
}

extension GameEngine: EngineEventsListener {
    func subscribeTo(_ publisher: EngineEventsPublisher) {
        subscriptions.sink(publisher) { [self] event in
            handleEngineEvent(event)
        }
    }

    private func handleEngineEvent(_ event: EngineEvent) {
        switch event {
        case .adventureFinalized(let adventure, let isDone):
            handleAdventureFinalized(adventure, isDone: isDone)
        default:
            break
        }
    }

    private func handleAdventureFinalized(_ adventure: Adventure, isDone: Bool) {
        adventureEngine = nil
        state.finalizedAdventure = adventure
        state.activeAdventure = nil

        if isDone {
            state.scenario.doneAdventure(adventure)
        }

        CacheService.shared.invalidateAll()
    }
}
