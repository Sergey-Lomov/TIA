//
//  JSONEncoder.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 12.07.2022.
//

import Foundation

extension JSONEncoder {

    static let snakeCaseEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    static func encodeLayout(_ layout: AdventureLayoutPrototype, into path: String) {
        guard let url = URL(string: path) else { return }
        guard let data = try? snakeCaseEncoder.encode(layout) else {
            return
        }
        try? data.write(to: url)
    }
}
