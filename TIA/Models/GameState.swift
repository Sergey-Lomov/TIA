//
//  GameState.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation

class GameState: ObservableObject {
    
    @Published var scenario = ScenarioService.shared.restoreScenario()
    @Published var activeAdventure: Adventure?
    
    func doneCurrentAdventure(theme: AdventureTheme) {
        scenario.doneCurrentAdventure(theme: theme)
    }
}
