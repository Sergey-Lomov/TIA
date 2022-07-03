//
//  IdEqutable.swift
//  TIA
//
//  Created by serhii.lomov on 03.05.2022.
//

import Foundation

protocol IdEqutable: Hashable {
    var id: String { get }
}

extension IdEqutable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
