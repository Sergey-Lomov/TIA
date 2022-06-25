//
//  MainMenuViewModel.swift
//  TIA
//
//  Created by serhii.lomov on 22.06.2022.
//

import Foundation
import Combine
import SwiftUI

enum MainMenuState: Equatable {
    case fromAdventure(adventure: AdventureDescriptor)
    case toAdventure(adventure: AdventureDescriptor)
    case regular
}

final class MainMenuViewModel: ObservableObject {
    
    private var subscriptions: [AnyCancellable] = []

    @Published var game: GameState
    @Published var state = MainMenuState.regular
    @Published var camera: CameraStatus = .fixed(state: .default)
    var cameraService: CameraService
    
    private var regularCameraState: CameraState { .default }

    init(game: GameState, cameraService: CameraService) {
        self.game = game
        self.cameraService = cameraService
        
        // Combine setup
        subscriptions.sink(game.objectWillChange) { [weak self] in
            self?.objectWillChange.sendOnMain()
        }
        
        subscriptions.sink($state) { [weak self] newState in
            guard let state = self?.state else { return }
            self?.handleStateSwitch(from: state, to: newState)
        }
    }
    
    private func handleStateSwitch(from oldState: MainMenuState, to newState: MainMenuState) {
        guard newState != .regular else { return }
        
        let old = cameraState(for: oldState)
        let new = cameraState(for: newState)
        let animation = cameraAnimation(newState)
        camera = .pretransition(from: old, to: new, animation: animation)
    }
    
    private func cameraState(for state: MainMenuState) -> CameraState {
        switch state {
        case .fromAdventure(let adventure), .toAdventure(let adventure):
            return cameraService.focusOnCurrentAdventure(adventure.theme)
        case .regular:
            return regularCameraState
        }
    }
    
    private func cameraAnimation(_ state: MainMenuState) -> Animation? {
        switch state {
        case .fromAdventure:
            return AnimationService.shared.fromAdventure
        case .toAdventure:
            return AnimationService.shared.toAdventure
        case .regular:
            return nil
        }
    }
}

// MARK: View interaction methods
extension MainMenuViewModel {
    func cameraApplied() {
        switch state {
        case .fromAdventure:
            state = .regular
        case .toAdventure(let adventure):
            if game.activeAdventure == nil {
                GameEngine.shared.startAdventure(adventure)
            }
        default:
            break
        }
    }
    
    func adventureSelected(_ adventure: AdventureDescriptor) {
        state = .toAdventure(adventure: adventure)
    }
}
