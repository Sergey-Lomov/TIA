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
    
    func doneCurrentAdventure(theme: AdventureTheme) {
        state.scenario.doneCurrentAdventure(theme: theme)
        adventureEngine = nil
    }
    
    func startAdventure(theme: AdventureTheme) {
        let current = state.scenario.currentAdventure(theme: theme)
        guard let descriptor = current else { return }
        
        let layout = AdventureLayout.random(for: descriptor)
        let adventure = ScenarioService.shared.adventureFor(descriptor, layout: layout)
        
        adventureEngine = AdventureEngine(adventure: adventure)
        state.activeAdventure = adventure
    }
    
    func availableIngameMenuItems() -> [IngameMenuItem] {
        return [.exit, .restart]
    }
}
