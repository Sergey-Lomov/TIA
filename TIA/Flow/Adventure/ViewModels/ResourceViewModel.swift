//
//  ResourceViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 26.04.2022.
//

import Foundation
import SwiftUI
import Combine

class ResourceViewModel: ObservableObject {
    
    var model: Resource
    @Published var color: Color
    @Published var borderColor: Color
    
    private var subscriptions: [AnyCancellable] = []
    
    var type: ResourceType {
        get { model.type }
        set { model.type = newValue }
    }
    
    var state: ResourceState {
        get { model.state }
        set { model.state = newValue }
    }
    
    init(model: Resource,
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
