//
//  Bundle.swift
//  TIA
//
//  Created by Serhii.Lomov on 12.04.2022.
//

import Foundation

extension Bundle {
    static func scenarioPath() -> String? {
        main.path(forResource: "scenario", ofType: "json")
    }

    static func adventurePath(id: String) -> String? {
        main.path(forResource: id, ofType: "json")
    }

    static func layoutPath(adventureId: String, index: Int) -> String? {
        main.path(forResource: "\(adventureId)_\(index)", ofType: "json")
    }
}
