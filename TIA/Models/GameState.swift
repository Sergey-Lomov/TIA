//
//  GameState.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation

class GameState: ObservableObject {
    
    @Published var scenario = ScenarioService.shared.restoreScenario()
    @Published private(set) var activeAdventure: AdventureVisualization?
    
    func doneCurrentAdventure(theme: AdventureTheme) {
        scenario.doneCurrentAdventure(theme: theme)
    }
    
    func setActiveAdventure(_ adventure: Adventure) {
        let visualizer = AdventureVisualizer(adventure: adventure)
        visualizer.updateVisualization()
        activeAdventure = visualizer.visualization
    }
}
