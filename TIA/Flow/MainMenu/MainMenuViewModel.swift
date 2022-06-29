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
            let descriptor = game.scenario.descriptorFor(finalized)
            guard let descriptor = descriptor else {
                fatalError("Finalized adventure missed in scenario")
            }
            self.state = .initAfterFinish(descriptor)
            let cameraState = cameraService.focusOnCurrentAdventure(finalized.theme)
            self.camera = .init(state: cameraState)
            iconFor(descriptor)?.state = .preclosing
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
//        subscriptions.sink(game.objectWillChange) { [weak self] in
//            self?.updateIcons()
//        }
        
        subscriptions.sink(camera.objectWillChange) { [weak self] in
            self?.objectWillChange.sendOnMain()
        }
    }
    
    private func initedAfterFinish(_ adventure: AdventureDescriptor) {
        state = .closing(adventure)
        iconFor(adventure)?.state = .closing
        let animation = AnimationService.shared.fromAdventure
        camera.transferTo(.default, animation: animation) { [weak self] in
            self?.closingFinished(adventure)
        }
    }
    
    private func closingFinished(_ adventure: AdventureDescriptor) {
        guard adventure.state == .done else {
            iconFor(adventure)?.state = .current
            state = .common
            return
        }
        
        guard let icon = iconFor(adventure) else { return }
        icon.state = .becameDone(slot: 0)
        let adventures = game.scenario.adventures[adventure.theme]
        let filtered = adventures?.filter { $0.state == .done && $0 != adventure }
        filtered?.forEach {
            let slot = icon.adventure.index - $0.index
            iconFor($0)?.state = .done(slot: slot)
        }
        if let next = game.scenario.currentAdventure(theme: adventure.theme) {
            iconFor(next)?.state = .becameCurrent
        }
    }
    
    private func icons(_ theme: AdventureTheme) -> [AdventureIconViewModel] {
        let adventures = game.scenario.adventures[theme] ?? []
        return adventures.map {
            AdventureIconViewModel(adventure: $0, state: stateFor($0))
        }
    }
    
    private func stateFor(_ adventure: AdventureDescriptor) -> AdventureIconState {
        switch state {
        case .common:
            return stableStateFor(adventure)
        case .opening(let associated):
            return associated == adventure ? .opening : stableStateFor(adventure)
        case .initAfterFinish(let associated):
            if associated == adventure {
                return .preclosing
            } else if associated.theme == adventure.theme {
                return adventure.state == .current ? .planed : stableStateFor(adventure)
            } else {
                return stableStateFor(adventure)
            }
        case .closing(let associated):
            return associated == adventure ? .closing : stableStateFor(adventure)
        }
    }

    private func stableStateFor(_ adventure: AdventureDescriptor) -> AdventureIconState {
        switch adventure.state {
        case .planed:
            return .planed
        case .current:
            return .current
        case .done:
            guard let adventures = game.scenario.adventures[adventure.theme] else {
                return .done(slot: 0)
            }
            var maxDone = adventures.filter({ $0.state == .done }).count
            
            switch state {
            case .initAfterFinish(let associated), .closing(let associated):
                if associated.theme == adventure.theme {
                    maxDone = maxDone - 1
                }
            default:
                break
            }
            
            let slot = maxDone - adventure.index
            return .done(slot: slot)
        }
    }

    private func iconFor(_ adventure: AdventureDescriptor) -> AdventureIconViewModel? {
        icons[adventure.theme]?.first { $0.adventure == adventure }
    }
}

// MARK: View interaction methods
extension MainMenuViewModel {
    func adventureSelected(_ adventure: AdventureDescriptor) {
        state = .opening(adventure)
        iconFor(adventure)?.state = .opening
        
        let to = cameraService.focusOnCurrentAdventure(adventure.theme)
        let animation = AnimationService.shared.toAdventure
        camera.transferTo(to, animation: animation, anchorAnimation: .final) { [weak self] in
            if self?.game.activeAdventure == nil {
                GameEngine.shared.startAdventure(adventure)
            }
        }
    }
}
