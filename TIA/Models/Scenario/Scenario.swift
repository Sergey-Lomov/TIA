//
//  Scenario.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation

class Scenario: ObservableObject {
    @Published var adventures: [AdventureTheme: [AdventureDescriptor]] = [:]
    
    init(adventures: [AdventureDescriptor]) {
        for theme in AdventureTheme.allCases {
            self.adventures[theme] = adventures.filter {
                $0.theme == theme
            }
        }
    }
    
    func currentAdventure(theme: AdventureTheme) -> AdventureDescriptor? {
        return adventures[theme]?.first { $0.state == .current }
    }
    
    func doneAdventure(_ adventure: Adventure) {
        guard let descriptor = descriptorFor(adventure) else { return }
        descriptor.state = .done
        let sorted = adventures[adventure.theme]?.sorted { $0.index < $1.index }
        let next = sorted?.first { $0.state == .planed }
        next?.state = .current
    }
    
    func descriptorFor(_ adventure: Adventure) -> AdventureDescriptor? {
        adventures[adventure.theme]?.first { $0.id == adventure.id }
    }
}
