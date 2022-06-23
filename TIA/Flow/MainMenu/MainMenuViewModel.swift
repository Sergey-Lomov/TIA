//
//  MainMenuViewModel.swift
//  TIA
//
//  Created by serhii.lomov on 22.06.2022.
//

import Foundation
import Combine

enum MainMenuState {
    case fromAdventure(adventure: AdventureDescriptor, preparing: Bool)
    case toAdventure(adventure: AdventureDescriptor)
    case regular
}

final class MainMenuViewModel: ObservableObject {
    
    private var subscriptions: [AnyCancellable] = []
    private var cameraService: CameraService
    
    @Published var game: GameState
    @Published var state = MainMenuState.regular
    
    private var regularCameraState: CameraState { .default }
    
    var camera: CameraStatus {
        switch state {
        case .fromAdventure(let adventure, let preparing):
            let state = cameraService.currentAdventureIcon(adventure.theme)
            if preparing {
                return .fixed(state: state)
            } else {
                let animation = AnimationService.shared.fromAdventure
                return .transition(to: regularCameraState, animation: animation)
            }
        case .toAdventure(let adventure):
            let state = cameraService.currentAdventureIcon(adventure.theme)
            let animation = AnimationService.shared.toAdventure
            return .transition(to: state, animation: animation)
        case .regular:
            return .fixed(state: regularCameraState)
        }
    }

    init(game: GameState, cameraService: CameraService) {
        self.game = game
        self.cameraService = cameraService
        
        // Combine setup
        subscriptions.sink(game.objectWillChange) { [weak self] in
            self?.objectWillChange.sendOnMain()
        }
    }
}

// MARK: View interaction methods
extension MainMenuViewModel {
    func cameraApplied() {
        switch state {
        case .fromAdventure(let adventure, let preparing):
            if preparing {
                state = .fromAdventure(adventure: adventure, preparing: false)
            } else {
                state = .regular
            }
        case .toAdventure(let adventure):
            GameEngine.shared.startAdventure(adventure)
        default:
            break
        }
    }
    
    func adventureSelected(_ adventure: AdventureDescriptor) {
        state = .toAdventure(adventure: adventure)
    }
}
