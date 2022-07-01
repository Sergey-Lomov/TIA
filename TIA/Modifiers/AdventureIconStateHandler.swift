//
//  AdventureIconStateHandler.swift
//  TIA
//
//  Created by serhii.lomov on 29.06.2022.
//

import SwiftUI

struct AdventureIconStateHandler: AnimatableModifier {
    
    private var transform: AdventureIconStateTransform

    public var animatableData: AdventureIconStateTransform {
        get { transform }
        set { transform = newValue }
    }
    
    init(transform: AdventureIconStateTransform) {
        self.transform = transform
    }
    
    func body(content: Content) -> some View {
        content
            .frame(size: transform.size)
            .offset(point: transform.offset)
            .rotationEffect(Angle(radians: transform.angle))
    }
}
