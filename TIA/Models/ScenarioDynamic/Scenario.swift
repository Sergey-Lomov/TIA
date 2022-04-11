//
//  Scenario.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation

class Scenario: ObservableObject {
    @Published var adventures: [AdventureTheme: [Adventure]] = [:]
    
    init(prototype: ScenarioPrototype,
         states: [String: AdventureState]) {
        for theme in AdventureTheme.allCases {
            let prototypes = prototype.adventures.filter {
                $0.theme == theme
            }

            adventures[theme] = prototypes.map {
                Adventure(prototype: $0)
            }

            adventures[theme]?.forEach {
                $0.state = states[$0.id] ?? .planed
            }
        }
    }
    
    func currentAdventure(theme: AdventureTheme) -> Adventure? {
        return adventures[theme]?.first { $0.state == .current }
    }
    
    func doneCurrentAdventure(theme: AdventureTheme) {
        guard let current = currentAdventure(theme: theme) else { return }
        
        current.state = .done
        let next = adventures[theme]?.first { $0.index == current.index + 1 }
        if let next = next {
            next.state = .current
        }
    }
}
