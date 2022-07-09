//
//  ScenarioService.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation
import CoreGraphics

final class ScenarioService {

    static func restoreScenario() -> Scenario {
        let states = StorageService.shared.getAdventuresStates()

        let protoScenario = JSONDecoder.decodeScenario()
        let adventures: [AdventureDescriptor] = protoScenario.adventures.map {
            let adventure = adventureDescriptor(id: $0)
            adventure.state = states[adventure.id] ?? .planed
            return adventure
        }

        let themes = [AdventureTheme.light, AdventureTheme.dark]
        themes.forEach { theme in
            let filtered = adventures.filter { $0.theme == theme }
            let noCurrent = !filtered.contains { $0.state == .current }
            guard noCurrent else { return }
            let planed = filtered.filter { $0.state == .planed }
            let sorted = planed.sorted { $0.index < $1.index }
            sorted.first?.state = .current
        }

        return Scenario(adventures: adventures)
    }

    static private func adventureDescriptor(id: String) -> AdventureDescriptor {
        let prototype = JSONDecoder.decodeAdventure(id: id)
        return AdventureDescriptor(id: prototype.id, index: prototype.index, theme: prototype.theme, doneShape: prototype.doneShape)
    }

    static func adventureFor(_ descriptor: AdventureDescriptor, layout: AdventureLayout) -> Adventure {
        let prototype = JSONDecoder.decodeAdventure(id: descriptor.id)
        let layer = layerFor(descriptor, layout: layout, forcedEntrance: nil)
        return Adventure(id: prototype.id, index: prototype.index, theme: prototype.theme, initialLayer: layer, doneShape: prototype.doneShape)
    }

    static func layerFor(_ descriptor: AdventureDescriptor, layout: AdventureLayout, forcedEntrance: Vertex? = nil) -> AdventureLayer {
        let protoAdventure = JSONDecoder.decodeAdventure(id: descriptor.id)
        return AdventureService.layerFor(protoAdventure, layout: layout, forcedEntrance: forcedEntrance)
    }
}
