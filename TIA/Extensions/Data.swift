//
//  Data.swift
//  TIA
//
//  Created by Serhii.Lomov on 12.04.2022.
//

import Foundation

extension Data {
    static func scenarioData() -> Data {
        guard let path = Bundle.scenarioPath() else {
            fatalError("Scenario json missed")
        }

        guard let data = try? String(contentsOfFile: path).data(using: .utf8) else {
            fatalError("Error at scenario json reading")
        }

        return data
    }

    static func adventureData(id: String) -> Data {
        guard let path = Bundle.adventurePath(id: id) else {
            fatalError("Adventure json missed for id \"\(id)\"")
        }

        guard let data = try? String(contentsOfFile: path).data(using: .utf8) else {
            fatalError("Error at adventure json reading for id \"\(id)\"")
        }

        return data
    }

    static func layoutData(adventureId: String, index: Int) -> Data {
        guard let path = Bundle.layoutPath(adventureId: adventureId, index: index) else {
            fatalError("Layout json missed for adventure \"\(adventureId)\" index \(index)")
        }

        guard let data = try? String(contentsOfFile: path).data(using: .utf8) else {
            fatalError("Error layout json parsing for adventure \"\(adventureId)\" index \(index)")
        }

        return data
    }
}
