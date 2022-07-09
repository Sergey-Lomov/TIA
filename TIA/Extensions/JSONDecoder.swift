//
//  JSONDecoder.swift
//  TIA
//
//  Created by Serhii.Lomov on 12.04.2022.
//

import Foundation

extension JSONDecoder {
    
    static let snakeCaseDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private func decode<T: Decodable>(_ data: Data, errorMessage: String) -> T {
        do {
            return try decode(T.self, from: data)
        } catch {
            var details = error.localizedDescription
            if let decodeError = error as? DecodingError {
                details = decodeError.detailedDescription
            }

            fatalError(errorMessage + "\n\(details)")
        }
    }

    static func decodeScenario() -> ScenarioPrototype {
        let data = Data.scenarioData()
        let message = "Error at parsing scenarion json"
        return snakeCaseDecoder.decode(data, errorMessage: message)
    }

    static func decodeAdventure(id: String) -> AdventurePrototype {
        let data = Data.adventureData(id: id)
        let message = "Error at parsing adventure json for id \"\(id)\""
        return snakeCaseDecoder.decode(data, errorMessage: message)
    }

    static func decodeLayout(adventureId: String, index: Int) -> AdventureLayout.Prototype {
        let data = Data.layoutData(adventureId: adventureId, index: index)
        let message = "Error at parsing adventure layout json for adventure \"\(adventureId)\" index \(index)"
        return snakeCaseDecoder.decode(data, errorMessage: message)
    }
}
