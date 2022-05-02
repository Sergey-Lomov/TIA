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
    
    @Namespace var wrapper: Namespace.ID
    @State var testBool = false
    let randomPoint = CGPoint.zero.randomPoint(maxDelta: 300)
    
    var body: some Scene {
        WindowGroup {
            if let adventure = game.activeAdventure,
               let player = GameEngine.shared.player,
               let resources = GameEngine.shared.resources {
                let viewModel = AdventureViewModel(
                    adventure,
                    player: player,
                    resources: resources,
                    listener: GameEngine.shared.adventureEngine,
                    eventsSource: GameEngine.shared.adventureEngine)

                AdventureView(adventure: viewModel)
            } else {
                MainMenuView(game: game)
            }
        }
    }
}
