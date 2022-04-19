//
//  Array.swift
//  TIA
//
//  Created by Serhii.Lomov on 12.04.2022.
//

import Foundation
import SwiftUI

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
        for i in 0...(count - 1) {
            let v1 = self[i, default: stub]
            let v2 = with[i, default: stub]
            result.append(merger(v1, v2))
        }
        return result
    }
}

extension Array where Element: Vertex {
    func firstById(_ id: String) -> Element? {
        return first { $0.id == id }
    }
}

extension Array where Element: Edge {
    func firstById(_ id: String) -> Element? {
        return first { $0.id == id }
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
        for i in 0...(count - 1) {
            self[i].scale(by: rhs)
        }
    }
    
    public var magnitudeSquared: Double {
        let magnitudes = map{ $0.magnitudeSquared }
        return magnitudes.reduce(into: 0) { $0 = $0 + $1}
    }
}
