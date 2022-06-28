//
//  AdventureIconViewModel.swift
//  TIA
//
//  Created by serhii.lomov on 27.06.2022.
//

import SwiftUI
import Combine

// TODO: Check all view models is final. Investigate other case, where final may be actual (services?). Try to setup SwiftLint.
final class AdventureIconViewModel: ObservableObject, IdEqutable {
    private var subscriptions: [AnyCancellable] = []
    
    @Published var adventure: AdventureDescriptor
    @Published var minimized: Bool
    @Published var animation: Animation?
    
    var id: String { adventure.id }
    
    init(adventure: AdventureDescriptor, minimized: Bool = false, animation: Animation? = nil) {
        self.adventure = adventure
        self.minimized = minimized
        self.animation = animation
        
        // TODO: Move this common case to custom property wrapper Transpublished
        subscriptions.sink(adventure.objectWillChange) { [weak self] in
            self?.objectWillChange.sendOnMain()
        }
    }
}
