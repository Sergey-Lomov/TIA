//
//  TIAApp.swift
//  TIA
//
//  Created by Serhii.Lomov on 06.04.2022.
//

import SwiftUI
import UIKit

@main
struct TIAApp: App {
    @ObservedObject var game = GameEngine.shared.state

    @Namespace var wrapper: Namespace.ID

    var body: some Scene {
        WindowGroup {
            CenteredGeometryReader { geometry in
                let cameraService = CameraService(safe: geometry.size, full: UIScreen.size)
                if let viewModel = adventureViewModel(cameraService) {
                    AdventureView(adventure: viewModel)
                } else {
                    MainMenuView(model: menuViewModel(cameraService))
                }
            }
        }
    }

    func menuViewModel(_ cameraService: CameraService) -> MainMenuViewModel {
        .init(game: game, cameraService: cameraService)
    }

    func adventureViewModel(_ cameraService: CameraService) -> AdventureViewModel? {
        guard let adventure = game.activeAdventure,
           let player = GameEngine.shared.player,
           let resources = GameEngine.shared.resources else {
               return nil
           }

        return .init(adventure,
                     cameraService: cameraService,
                     player: player,
                     resources: resources,
                     listener: GameEngine.shared.adventureEngine,
                     eventsSource: GameEngine.shared.adventureEngine)
    }
}
