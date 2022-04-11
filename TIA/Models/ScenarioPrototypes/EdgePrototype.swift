//
//  EdgePrototype.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation

struct EdgePrototype {
    let from: VertexPrototype
    let to: VertexPrototype
    let price: [Resource]
    let growOnStart: Bool
    
    init(from: VertexPrototype,
         to: VertexPrototype,
         price: [Resource] = [],
         growOnStart: Bool = true) {
        self.from = from
        self.to = to
        self.price = price
        self.growOnStart = growOnStart
    }
}
