//
//  AdventureViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 13.04.2022.
//

import Foundation
import SwiftUI
import Combine

final class AdventureViewModel: ObservableObject {
    
    var model: Adventure
    @Published var vertices: [VertexViewModel]
    @Published var edges: [EdgeViewModel]
    
    init(_ adventure: Adventure) {
        self.model = adventure

        let vertexColor = Color.inversedFor(adventure.theme)
        self.vertices = adventure.vertices.map {
            return VertexViewModel(vertex: $0,
                                   isCurrent: false,
                                   color: vertexColor)
        }
        
        let edgeColor = Color.inversedFor(adventure.theme)
        let borderColor = Color.mainFor(adventure.theme)
        self.edges = adventure.edges.map {
            return EdgeViewModel(model: $0,
                                 color: edgeColor,
                                 borderColor: borderColor)
        }
    }
}
