//
//  IngameMenuViewModel.swift
//  TIA
//
//  Created by serhii.lomov on 14.05.2022.
//

import Foundation
import SwiftUI
import Combine

class IngameMenuViewModel: ObservableObject {
    var eventsPublisher: ViewEventsPublisher?
    
    var model: IngameMenuModel
    @Published var color: Color
    @Published var symbolColor: Color
    
    var state: IngameMenuState { model.state }
    var vertex: Vertex { model.vertex }
    
    private var subscriptions: [AnyCancellable] = []
    
    init(model: IngameMenuModel, color: Color, symbolColor: Color) {
        self.model = model
        self.color = color
        self.symbolColor = symbolColor
        
        subscriptions.sink(model.objectWillChange) { [weak self] in
            self?.objectWillChange.sendOnMain()
        }
    }
}

// MARK: View interaction methods
extension VertexViewModel {
    func didTapped() {
        
    }
}
