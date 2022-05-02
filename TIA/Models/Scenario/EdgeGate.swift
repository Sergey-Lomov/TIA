//
//  EdgeGate.swift
//  TIA
//
//  Created by serhii.lomov on 02.05.2022.
//

import Foundation
import CoreGraphics

enum EdgeGateRequirement {
    case resource(ResourceType)
}

class EdgeGate: ObservableObject {
    let id = UUID().uuidString
    let requirement: EdgeGateRequirement
    @Published var isOpen: Bool = false
    
    init(requirement: EdgeGateRequirement) {
        self.requirement = requirement
    }
}
