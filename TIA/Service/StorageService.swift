//
//  StorageService.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation

class StorageService {
    
    static let shared = StorageService()
    
    func getAdventuresStates() -> [String: AdventureState] {
        return ["dark1": .current, "light1": .current]
    }
}
