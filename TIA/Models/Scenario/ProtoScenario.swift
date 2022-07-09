//
//  ProtoScenario.swift
//  TIA
//
//  Created by serhii.lomov on 06.07.2022.
//

import Foundation

struct ScenarioPrototype: Codable {
    let adventures: [String]
}

struct AdventurePrototype: Codable {
    let id: String
    let index: Int
    let theme: AdventureTheme
    let doneShape: AdventureDoneShape
    var vertices: [VertexPrototype]
    var edges: [EdgePrototype]

    func copy() -> AdventurePrototype {
        let vertices = vertices.map { $0.copy() }
        let edges = edges.map { $0.copy() }
        return .init(id: id, index: index, theme: theme, doneShape: doneShape, vertices: vertices, edges: edges)
    }

    mutating func updateVertexId(_ id: String, to newId: String) {
        for i in 0..<vertices.count where vertices[i].id == id {
            vertices[i].id = newId
        }
        for i in 0..<edges.count {
            if edges[i].from == id { edges[i].from = newId }
            if edges[i].to == id { edges[i].to = newId }
        }
    }
}


enum VertexRole: String, Codable {
    case entrance
    case common
    case exit
}

struct VertexPrototype: Codable {
    var id: String
    let role: VertexRole
    let resources: [ResourceType]

    func copy() -> VertexPrototype {
        .init(id: id, role: role, resources: resources)
    }
}

struct EdgePrototype: Codable {
    let id: String
    var from: String
    var to: String
    let price: [ResourceType]
    let growOnStart: Bool

    func copy() -> EdgePrototype {
        let price = [ResourceType](price)
        return .init(id: id, from: from, to: to, price: price, growOnStart: growOnStart)
    }
}
