//
//  AdventureDescriptor.swift
//  TIA
//
//  Created by Serhii.Lomov on 16.04.2022.
//

import Foundation

final class AdventureDescriptor: ObservableObject, IdEqutable {
    let id: String
    let index: Int
    var theme: AdventureTheme
    @Published var state: AdventureState = .planed
    
    init(id: String, index: Int, theme: AdventureTheme) {
        self.id = id
        self.index = index
        self.theme = theme
    }
    
    init(_ adventure: Adventure) {
        self.id = adventure.id
        self.index = adventure.index
        self.theme = adventure.theme
    }
}
