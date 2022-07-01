//
//  AnimationState.swift
//  TIA
//
//  Created by Serhii.Lomov on 20.04.2022.
//

import Foundation
import CoreGraphics
import SwiftUI

protocol AnimationStateProtocol {
    associatedtype Value: VectorArithmetic

    var progress: CGFloat { get }
    var value: Value { get }
    var timing: BezierCurve { get }

    init(progress: CGFloat, value: Value, timing: BezierCurve)
    func normalized() -> Self
}

struct AnimationState<Value>: AnimationStateProtocol where Value: VectorArithmetic {
    let progress: CGFloat
    let value: Value
    let timing: BezierCurve

    func normalized() -> Self {
        let progress = progress.normalized(min: 0, max: 1)
        return Self(progress: progress, value: value, timing: timing)
    }
}

class AnimationStatesContainer<Value> where Value: VectorArithmetic {
    typealias State = AnimationState<Value>

    let states: [State]

    init(states: [State]) {
        self.states = states.normalized()
    }

    func valueFor(_ progress: CGFloat) -> Value {
        for i in 0...(states.count - 2) {
            guard let localProgress = localProgress(index: i, global: progress) else {
                continue
            }

            let startValue = states[i].value
            let finishValue = states[i + 1].value
            let mult = states[i].timing.getY(t: localProgress)
            var apendix = (finishValue - startValue)
            apendix.scale(by: mult)
            return startValue + apendix
        }

        return .zero
    }

    private func localProgress(index i: Int, global: CGFloat) -> CGFloat? {
        guard i < states.count - 1 else { return nil } // Last state should be used only like an interval fnish, not start

        let current = states[i].progress
        let next = states[i + 1].progress
        guard current <= global && next >= global else {
            return nil
        }

        let delta = global - current
        return delta == 0 ? 0 : (next - current) / delta
    }
}

extension Array where Element: AnimationStateProtocol {

    func normalized() -> [Element] {
        guard let first = first, let last = last else {
              fatalError("Animation states shouldn't be empty ")
          }

        var normalized = map { $0.normalized() }

        if first.progress > 0 {
            let state = Element(progress: 0, value: first.value, timing: .linearTiming)
            normalized.insert(state, at: 0)
        }

        if last.progress < 1 {
            let state = Element(progress: 1, value: last.value, timing: .linearTiming)
            normalized.insert(state, at: 0)
        }

        return normalized.sorted {$0.progress < $1.progress}
    }

    mutating func add(_ progress: CGFloat, _ value: Element.Value, _ timing: BezierCurve = .linearTiming) {
        append(Element(progress: progress, value: value, timing: timing))
    }
}
