//
//  EdgeViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 16.04.2022.
//

import Foundation
import SwiftUI
import Combine

class EdgeViewModel: ObservableObject {
    var eventsPublisher: ViewEventsPublisher?
    
    @Published var model: Edge
    @Published var color: Color
    @Published var borderColor: Color
    
    private var subscriptions: [AnyCancellable] = []
    
    var curve: BezierCurve {
        get { model.curve }
        set { model.curve = newValue }
    }
    
    init(model: Edge,
         color: Color,
         borderColor: Color) {
        self.model = model
        self.color = color
        self.borderColor = borderColor
        
        let subscription = model.objectWillChange.sink {
            [weak self] _ in
            self?.objectWillChange.send()
        }
        subscriptions.append(subscription)
    }
}

// MARK: View interaction methods
extension EdgeViewModel {
    func growingFinished() {
        eventsPublisher?.send(.edgeGrowingFinished(edge: model))
    }
}
