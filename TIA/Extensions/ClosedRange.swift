//
//  ClosedRange.swift
//  TIA
//
//  Created by serhii.lomov on 27.05.2022.
//

import Foundation
import CoreGraphics

typealias FloatRange = ClosedRange<CGFloat>

extension ClosedRange {

    init(from: Bound, to: Bound) {
        self = from ... to
    }
}
