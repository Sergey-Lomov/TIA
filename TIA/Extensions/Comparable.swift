//
//  Comparable.swift
//  TIA
//
//  Created by Serhii.Lomov on 11.04.2022.
//

import Foundation

extension Comparable {
    func normalized(min: Self, max: Self) -> Self {
        switch self {
        case let value where value > max:
            return max
        case let value where value < min:
            return min
        default:
            return self
        }
    }
}
