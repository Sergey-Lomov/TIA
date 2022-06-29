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
    let theme: AdventureTheme
    let doneShape: AdventureDoneShape
    @Published var state: AdventureState = .planed
    
    init(id: String, index: Int, theme: AdventureTheme, doneShape: AdventureDoneShape) {
        self.id = id
        self.index = index
        self.theme = theme
        self.doneShape = doneShape
    }
}
