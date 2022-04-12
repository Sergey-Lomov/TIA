//
//  AdventureVisualization.swift
//  TIA
//
//  Created by Serhii.Lomov on 12.04.2022.
//

import CoreGraphics
import Combine

// TODO: For now this class is unused. If this really not necessary it sohudl be removed
class AdventureVisualization: ObservableObject {
    @Published var model: Adventure
    var vertices: [VertexVisualization] = []
    var edges: [EdgeVisualization] = []
    
    init(model: Adventure) {
        self.model = model
    }
}

struct VertexVisualization {
    var model: Vertex
    var position: CGPoint
}

struct EdgeVisualization {
    var model: Edge
    var curve: BezierCurve
}
