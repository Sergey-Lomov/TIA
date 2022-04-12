//
//  Vertex.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import CoreGraphics

enum VertexType: Codable {
    case tools
    case entrance
    case common
    case exit
}

class Vertex {
    var id: String
    var type: VertexType
    var resources: [Resource]
    
    init(id: String,
         type: VertexType = .common,
         resources: [Resource] = []) {
        self.id = id
        self.type = type
        self.resources = resources
    }
}
