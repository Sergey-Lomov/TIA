//
//  Adventure.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation

enum AdventureTheme: String, Codable, CaseIterable {
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
    
    private static let menuEdgePrefix = "menu_edge_"

    let id: String
    let index: Int
    var theme: AdventureTheme
    @Published var layers: [AdventureLayer]
    @Published var currentLayer: AdventureLayer
    
    var allVertices: [Vertex] {
        layers.flatMap { $0.vertices }
    }
    
    var allEdges: [Edge] {
        layers.flatMap { $0.edges }
    }
    
    init(id: String, index: Int, theme: AdventureTheme, initialLayer: AdventureLayer) {
        self.id = id
        self.index = index
        self.theme = theme
        
        self.layers = [initialLayer]
        self.currentLayer = initialLayer
    }
}
