//
//  VectorArithmetic.swift
//  TIA
//
//  Created by serhii.lomov on 02.07.2022.
//

import Foundation
import SwiftUI

extension VectorArithmetic {
    
    static func *= (lhs: inout Self, rhs: Double) {
        lhs.scale(by: rhs)
    }
}
