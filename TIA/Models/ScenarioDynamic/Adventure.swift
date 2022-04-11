//
//  Adventure.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation

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
    
    var currentVertex: Vertex?
    var playerResources: [Resource] = []
    @Published var state: AdventureState = .planed
    
    init(prototype: AdventurePrototype) {
        id = prototype.id
        index = prototype.index
        theme = prototype.theme
        
        let vertices = prototype.vertices.map {
            Vertex(prototype: $0)
        }
        self.vertices = vertices
        
        edges = prototype.edges.compactMap {
            do {
                return try Edge(prototype: $0, vertices: vertices)
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
    }
}
