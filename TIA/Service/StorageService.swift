//
//  StorageService.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation

final class StorageService {

    static let shared = StorageService()

    private let gameProgressKey = "game_progress"

    func getAdventuresStates() -> [String: AdventureState] {
        let storedStates = UserDefaults.standard.object(forKey: gameProgressKey)
        let rawStates = storedStates as? [String: String] ?? [:]
        return rawStates.mapValues { AdventureState(rawValue: $0) ?? .planed }
    }

    func saveAdventureState(_ states: [String: AdventureState]) {
        let rawState = states.mapValues { $0.rawValue }
        UserDefaults.standard.set(rawState, forKey: gameProgressKey)
    }
}
