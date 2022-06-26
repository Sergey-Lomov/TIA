//
//  MainMenuViewModel.swift
//  TIA
//
//  Created by serhii.lomov on 22.06.2022.
//

import Foundation
import Combine
import SwiftUI

final class MainMenuViewModel: ObservableObject {
    
    private var subscriptions: [AnyCancellable] = []

    @Published var game: GameState
    @Published var camera: CameraViewModel
    var cameraService: CameraService
    
    init(game: GameState, cameraService: CameraService) {
        self.game = game
        self.cameraService = cameraService
        
        if let finalized = game.finalizedAdventure {
            let from = cameraService.focusOnCurrentAdventure(finalized.theme)
            let animation = AnimationService.shared.fromAdventure
            self.camera = .init(state: from)
            self.camera.completion = {
                self.camera.transferTo(.default, animation: animation)
                game.finalizedAdventure = nil
            }
        } else {
            self.camera = .init(state: .default)
        }
        
        // Combine setup
        subscriptions.sink(game.objectWillChange) { [weak self] in
            self?.objectWillChange.sendOnMain()
        }
        
        subscriptions.sink(camera.objectWillChange) { [weak self] in
            self?.objectWillChange.sendOnMain()
        }
    }
}

// MARK: View interaction methods
extension MainMenuViewModel {
    func adventureSelected(_ adventure: AdventureDescriptor) {
        let to = cameraService.focusOnCurrentAdventure(adventure.theme)
        let animation = AnimationService.shared.toAdventure
        camera.transferTo(to, animation: animation, anchorAnimation: .final) { [weak self] in
            if self?.game.activeAdventure == nil {
                GameEngine.shared.startAdventure(adventure)
            }
        }
    }
}
