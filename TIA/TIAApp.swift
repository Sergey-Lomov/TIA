//
//  TIAApp.swift
//  TIA
//
//  Created by Serhii.Lomov on 06.04.2022.
//

import SwiftUI

@main
struct TIAApp: App {
    @ObservedObject var game = GameEngine.shared.state
    
    var body: some Scene {
        WindowGroup {
            if let adventure = game.activeAdventure {
                let viewModel = AdventureViewModel(adventure)
                AdventureView(adventure: viewModel)
                    .onAppear {
                        GameEngine.shared.adventureEngine?.growFromEntrace()
                    }
            } else {
                MainMenuView(game: game)
            }
        }
    }
}
