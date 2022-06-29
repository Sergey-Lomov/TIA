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

enum AdventureDoneShape: String, Codable {
    case star8
    case poly7
}

class Adventure: ObservableObject {
    
    private static let menuEdgePrefix = "menu_edge_"

    let id: String
    let index: Int
    let theme: AdventureTheme
    let doneShape: AdventureDoneShape
    @Published var layers: [AdventureLayer]
    @Published var currentLayer: AdventureLayer
    
    var allVertices: [Vertex] {
        layers.flatMap { $0.vertices }
    }
    
    var allEdges: [Edge] {
        layers.flatMap { $0.edges }
    }
    
    init(id: String, index: Int, theme: AdventureTheme, initialLayer: AdventureLayer, doneShape: AdventureDoneShape) {
        self.id = id
        self.index = index
        self.theme = theme
        self.doneShape = doneShape
        
        self.layers = [initialLayer]
        self.currentLayer = initialLayer
    }
}
