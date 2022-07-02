//
//  AnimationCompletionObserverModifier.swift
//  TIA
//
//  Created by serhii.lomov on 27.05.2022.
//

import Foundation
import SwiftUI

struct AnimationCompletionObserverModifier<Value>: AnimatableModifier where Value: VectorArithmetic {

    var animatableData: Value {
        didSet {
            notifyCompletionIfFinished()
        }
    }

    private var targetValue: Value
    private var completion: Action

    init(observedValue: Value, completion: @escaping Action) {
        self.completion = completion
        self.animatableData = observedValue
        self.targetValue = observedValue
    }

    private func notifyCompletionIfFinished() {
        guard animatableData == targetValue else { return }

        DispatchQueue.main.async {
            self.completion()
        }
    }

    func body(content: Content) -> some View {
        return content
    }
}
