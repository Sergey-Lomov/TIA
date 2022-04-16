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
    
    func doneCurrentAdventure(theme: AdventureTheme) {
        guard let current = currentAdventure(theme: theme) else { return }
        
        current.state = .done
        let next = adventures[theme]?.first { $0.index == current.index + 1 }
        if let next = next {
            next.state = .current
        }
    }
}
