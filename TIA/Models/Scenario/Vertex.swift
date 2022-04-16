//
//  Vertex.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation
import CoreGraphics
import Combine

enum VertexType: String, Codable {
    case tools
    case entrance
    case common
    case exit
}

enum VertexState {
    case seed
    case growing(duration: TimeInterval)
    case active
}

class Vertex: ObservableObject {
    var id: String
    var type: VertexType
    @Published var state: VertexState
    var point: CGPoint
    var resources: [Resource]
    var inEdges: [Edge] = []
    var outEdges: [Edge] = []
    
    init(id: String,
         type: VertexType = .common,
         state: VertexState = .seed,
         point: CGPoint,
         resources: [Resource] = []) {
        self.id = id
        self.type = type
        self.state = state
        self.point = point
        self.resources = resources
    }
}
