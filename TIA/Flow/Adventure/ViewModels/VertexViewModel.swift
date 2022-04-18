//
//  VertexViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 16.04.2022.
//

import Foundation
import SwiftUI
import Combine

class VertexViewModel: ObservableObject {
    @Published var model: Vertex
    @Published var isCurrent: Bool
    @Published var color: Color
    
    var state: VertexState {
        get { model.state }
        set { model.state = newValue }
    }
    
    var type: VertexType {
        get { model.type }
        set { model.type = newValue }
    }
    
    var point: CGPoint {
        get { model.point }
        set { model.point = newValue }
    }
    
    private var subscriptions: [AnyCancellable] = []
    
    init(vertex: Vertex,
         isCurrent: Bool = false,
         color: Color) {
        self.model = vertex
        self.isCurrent = isCurrent
        self.color = color
        
        let subscription = model.objectWillChange.sink {
            [weak self] _ in
            self?.objectWillChange.send()
        }
        subscriptions.append(subscription)
    }
}
