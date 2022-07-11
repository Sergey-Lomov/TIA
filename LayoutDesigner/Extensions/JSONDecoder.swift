//
//  JSONDecoder.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 10.07.2022.
//

import Foundation

extension JSONDecoder {

    static let snakeCaseDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    static func decodeAdventure(_ path: String) -> AdventurePrototype? {
        decodeByPath(path)
    }

    static func decodeLayout(_ path: String) -> AdventureLayout.Prototype? {
        decodeByPath(path)
    }

    private static func decodeByPath<T: Decodable>(_ path: String) -> T? {
        guard let url = URL(string: path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let result = try snakeCaseDecoder.decode(T.self, from: data)
            return result
        } catch {
            print(error)
            return nil
        }
    }
}
