//
//  Array.swift
//  TIA
//
//  Created by Serhii.Lomov on 12.04.2022.
//

import Foundation

extension Array where Element : Vertex {
    func firstById(_ id: String) -> Element? {
        return first { $0.id == id }
    }
}
