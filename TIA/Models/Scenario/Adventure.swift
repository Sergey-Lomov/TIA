//
//  Adventure.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation

enum AdventureTheme: Codable, CaseIterable {
    case dark
    case light
    case truth
}

enum AdventureState {
    case done
    case current
    case planed
}

class Adventure: ObservableObject {
    let id: String
    let index: Int
    var theme: AdventureTheme
    var vertices: [Vertex]
    var edges: [Edge]
    
    @Published var state: AdventureState = .planed
    
    init(id: String,
         index: Int,
         theme: AdventureTheme,
         vertices: [Vertex],
         edges: [Edge]) {
        self.id = id
        self.index = index
        self.theme = theme
        self.vertices = vertices
        self.edges = edges
    }
}
