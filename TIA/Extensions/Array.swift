//
//  Array.swift
//  TIA
//
//  Created by Serhii.Lomov on 12.04.2022.
//

import Foundation
import SwiftUI
import Combine

extension Array {
    public subscript(index: Int, default defaultValue: @autoclosure () -> Element) -> Element {
        guard index >= 0, index < endIndex else {
            return defaultValue()
        }

        return self[index]
    }
    
    public func merged(with: Array<Element>,
                       stub: Element,
                       merger: (Element, Element) -> Element) -> Array<Element> {
        var result = [Element]()
        let count = Swift.max(self.count, with.count)
        for i in 0..<count {
            let v1 = self[i, default: stub]
            let v2 = with[i, default: stub]
            result.append(merger(v1, v2))
        }
        return result
    }
    
    func allSatisfy(validator: (Element) -> Bool) -> Bool {
        for element in self {
            if !validator(element) { return false }
        }
        return true
    }
}

extension Array where Element: Equatable & Hashable {
    func intersection(_ array: Array<Element>) -> Array<Element> {
        return Array(Set(self).intersection(Set(array)))
    }
}

extension Array where Element: AdditiveArithmetic {
    
    public func merged(with: Array<Element>,
                       merger: (Element, Element) -> Element) -> Array<Element> {
        return merged(with: with, stub: .zero, merger: merger)
    }

    public static var zero: Array<Element> {
        return [Element]()
    }
}

extension Array where Element: VectorArithmetic {
    public mutating func scale(by rhs: Double) {
        for i in 0..<count {
            self[i].scale(by: rhs)
        }
    }
    
    public var magnitudeSquared: Double {
        let magnitudes = map{ $0.magnitudeSquared }
        return magnitudes.reduce(into: 0) { $0 = $0 + $1}
    }
}

extension Array where Element == AnyCancellable {
    mutating func sink<P: Publisher>(_ publisher: P, handler: @escaping (P.Output) -> Void) where P.Failure == Never {
        let subscription = publisher.sink { handler($0) }
        self.append(subscription)
    }
    
    mutating func sink<P: Publisher>(_ publisher: P, handler: @escaping () -> Void) where P.Failure == Never {
        let subscription = publisher.sink { _ in handler() }
        self.append(subscription)
    }
}

extension Array where Element: IdEqutable {
    func firstById(_ id: String) -> Element? {
        return first { $0.id == id }
    }
}

extension Array where Element: Equatable {
    mutating func remove(_ element: Element) {
        self = filter { $0 != element }
    }
}
