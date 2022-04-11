//
//  AdventureVisualization.swift
//  TIA
//
//  Created by Serhii.Lomov on 12.04.2022.
//

import CoreGraphics

struct AdventureVisualization {
    var model: Adventure
    var vertices: [VertexVisualization]
    var edges: [EdgeVisualization]
}

struct VertexVisualization {
    var model: Vertex
    var position: CGPoint
}

struct EdgeVisualization {
    var model: Edge
    var curve: BezierCurve
}
