//
//  StorageService.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation

enum AdventureСompleteness: String, Codable {
    case done
    case current
    case planed
}

final class StorageService {

    static let shared = StorageService()

    private let gameProgressKey = "game_progress"

    func getAdventuresStates() -> [String: AdventureСompleteness] {
        let storedStates = UserDefaults.standard.object(forKey: gameProgressKey)
        let rawStates = storedStates as? [String: String] ?? [:]
        return rawStates.mapValues { AdventureСompleteness(rawValue: $0) ?? .planed }
    }

    func saveAdventureState(_ states: [String: AdventureСompleteness]) {
        let rawState = states.mapValues { $0.rawValue }
        UserDefaults.standard.set(rawState, forKey: gameProgressKey)
    }
}
