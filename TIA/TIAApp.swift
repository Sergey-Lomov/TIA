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
        let adventure = GameEngine.shared.adventureEngine?.adventure
        let resources = GameEngine.shared.adventureEngine?.resources
        let player = GameEngine.shared.adventureEngine?.player
        guard let adventure = adventure, let player = player, let resources = resources else {
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
