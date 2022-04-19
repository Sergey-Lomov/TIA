//
//  Shape.swift
//  TIA
//
//  Created by Serhii.Lomov on 19.04.2022.
//

import Foundation
import SwiftUI

extension Shape {
    func onReach(_ value: AnimatableData,
                 handler: @escaping () -> Void) -> some Shape {
        AnimationHandlingShape(content: self, target: value, handler: handler)
    }
}
