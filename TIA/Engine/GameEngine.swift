//
//  GameEngine.swift
//  TIA
//
//  Created by Serhii.Lomov on 15.04.2022.
//

import Foundation

final class GameEngine {

    static let shared = GameEngine(state: GameState())

    let state: GameState
    var adventureEngine: AdventureEngine?

    var player: Player? { adventureEngine?.player }
    var resources: [Resource]? { adventureEngine?.resources }

    init(state: GameState) {
        self.state = state
    }

    func finalizeAdenture(_ adventure: Adventure, isDone: Bool) {
        adventureEngine = nil
        state.finalizedAdventure = adventure
        state.activeAdventure = nil

        if isDone {
            state.scenario.doneAdventure(adventure)
        }
    }

    func startAdventure(_ descriptor: AdventureDescriptor) {
        let layout = AdventureLayout.random(for: descriptor.id)
        let adventure = ScenarioService.shared.adventureFor(descriptor, layout: layout)

        adventureEngine = AdventureEngine(adventure: adventure)
        state.activeAdventure = adventure
    }

    func availableIngameMenuItems() -> [IngameMenuItem] {
        return [.exit, .restart]
    }
}
