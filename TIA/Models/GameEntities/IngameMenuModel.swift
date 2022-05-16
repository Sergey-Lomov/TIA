//
//  IngameMenuModel.swift
//  TIA
//
//  Created by serhii.lomov on 14.05.2022.
//

import Foundation

enum IngameMenuState {
    case abscent
    case closed
    case opened
    case visited
}

final class IngameMenuModel: ObservableObject {
    
    @Published var state: IngameMenuState = .closed
    @Published var vertex: Vertex
    
    init(vertex: Vertex) {
        self.vertex = vertex
    }
}
