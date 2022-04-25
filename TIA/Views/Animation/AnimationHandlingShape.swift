//
//  UpdateHandlerView.swift
//  TIA
//
//  Created by Serhii.Lomov on 17.04.2022.
//

import Foundation
import SwiftUI

struct AnimationHandlingShape<T: Shape>: Shape {
    
    var content: T
    var target: T.AnimatableData
    var handler: (() -> Void)?
    
    var animatableData: T.AnimatableData {
        get { content.animatableData }
        set {
            content.animatableData = newValue
            if newValue == target {
                handler?()
                handler = nil
            }
        }
    }
    
    init(content: T, target: T.AnimatableData, handler:
    @escaping () -> Void) {
        self.content = content
        self.target = target
        self.handler = handler
    }
    
    func path(in rect: CGRect) -> Path {
        content.path(in: rect)
    }
}
