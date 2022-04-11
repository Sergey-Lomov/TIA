//
//  Vertex.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation

class Vertex {
    var id: String
    var type: VertexType
    var resources: [Resource]
    
    init(prototype: VertexPrototype) {
        id = prototype.id
        type = prototype.type
        resources = prototype.resources
    }
}
