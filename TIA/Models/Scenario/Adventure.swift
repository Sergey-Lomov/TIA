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
    
    init(id: String, index: Int, theme: AdventureTheme, vertices: [Vertex], edges: [Edge], entrance: Vertex) {
        self.id = id
        self.index = index
        self.theme = theme
        
        let layer = AdventureLayer(type: .initial, state: .growing, vertices: vertices, edges: edges, entrance: entrance)
        self.layers = [layer]
        self.currentLayer = layer
    }
}
