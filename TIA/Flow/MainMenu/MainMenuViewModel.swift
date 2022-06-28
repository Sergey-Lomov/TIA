//
//  MainMenuViewModel.swift
//  TIA
//
//  Created by serhii.lomov on 22.06.2022.
//

import Foundation
import Combine
import SwiftUI

private enum MainMenuState {
    case common
    case opening(_ adventure: AdventureDescriptor)
    case initAfterFinish(_ adventure: AdventureDescriptor)
    case closing(_ adventure: AdventureDescriptor)
}

final class MainMenuViewModel: ObservableObject {
    
    private var subscriptions: [AnyCancellable] = []
    
    private var state: MainMenuState
    private var game: GameState
    @Published var camera: CameraViewModel
    @Published var icons: [AdventureTheme: [AdventureIconViewModel]] = [:]
    var cameraService: CameraService
    
    init(game: GameState, cameraService: CameraService) {
        self.game = game
        self.cameraService = cameraService
                
        if let finalized = game.finalizedAdventure {
            let descriptor = AdventureDescriptor(finalized)
            self.state = .initAfterFinish(descriptor)
            let cameraState = cameraService.focusOnCurrentAdventure(finalized.theme)
            self.camera = .init(state: cameraState)
            self.camera.completion = { [weak self] in
                self?.initedAfterFinish(descriptor)
            }
        } else {
            self.state = .common
            self.camera = .init(state: .default)
        }
        
        AdventureTheme.allCases.forEach {
            self.icons[$0] = icons($0)
        }
        
        // Combine setup
        subscriptions.sink(game.objectWillChange) { [weak self] in
            self?.updateIcons()
        }
        
        subscriptions.sink(camera.objectWillChange) { [weak self] in
            self?.objectWillChange.sendOnMain()
        }
    }
    
    private func initedAfterFinish(_ adventure: AdventureDescriptor) {
        state = .closing(adventure)
        let animation = AnimationService.shared.fromAdventure
        iconFor(adventure)?.minimized = false
        iconFor(adventure)?.animation = animation
        camera.transferTo(.default, animation: animation) { [weak self] in
            self?.state = .common
        }
    }
    
    private func updateIcons() {
        AdventureTheme.allCases.forEach { theme in
            icons[theme]?.forEach { icon in
                icon.minimized = isMinimized(icon.adventure)
                icon.animation = iconAnimation(icon.adventure)
            }
        }
    }
    
    private func icons(_ theme: AdventureTheme) -> [AdventureIconViewModel] {
        let icons = game.scenario.adventures[theme]?.map {
            AdventureIconViewModel(adventure: $0, minimized: isMinimized($0), animation: iconAnimation($0))
        }
        return icons ?? []
    }
    
    private func isMinimized(_ adventure: AdventureDescriptor) -> Bool {
        switch state {
        case .opening(let associated),
                .initAfterFinish(let associated):
            return associated.id == adventure.id
        default:
            return false
        }
    }
    
    private func iconAnimation(_ adventure: AdventureDescriptor) -> Animation? {
        switch state {
        case .opening(let associated):
            if associated.id == adventure.id {
                return AnimationService.shared.toAdventure
            }
        case .closing(let associated):
            if associated.id == adventure.id {
                return AnimationService.shared.fromAdventure
            }
        default:
            break
        }
        
        return nil
    }
    
    private func iconFor(_ adventure: AdventureDescriptor) -> AdventureIconViewModel? {
        icons[adventure.theme]?.first { $0.adventure == adventure }
    }
}

// MARK: View interaction methods
extension MainMenuViewModel {
    func adventureSelected(_ adventure: AdventureDescriptor) {
        state = .opening(adventure)
        
        let animation = AnimationService.shared.toAdventure
        iconFor(adventure)?.minimized = true
        iconFor(adventure)?.animation = animation
        
        let to = cameraService.focusOnCurrentAdventure(adventure.theme)
        camera.transferTo(to, animation: animation, anchorAnimation: .final) { [weak self] in
            if self?.game.activeAdventure == nil {
                GameEngine.shared.startAdventure(adventure)
            }
        }
    }
}
