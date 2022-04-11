//
//  AdventurePrototype.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation

enum AdventureTheme: CaseIterable {
    case dark
    case light
    case truth
}

struct AdventurePrototype {
    let id: String
    let index: Int
    let theme: AdventureTheme
    let vertices: [VertexPrototype]
    let edges: [EdgePrototype]
}
