//
//  Vertex.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation

enum VertexType {
    case tools
    case entrance
    case intermediate
    case exit
}

struct VertexPrototype {
    let id = UUID().uuidString
    let type: VertexType
    let resources: [Resource]
}
