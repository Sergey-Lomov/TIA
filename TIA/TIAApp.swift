//
//  TIAApp.swift
//  TIA
//
//  Created by Serhii.Lomov on 06.04.2022.
//

import SwiftUI

@main
struct TIAApp: App {
    @StateObject var game = GameState()
    
    var body: some Scene {
        WindowGroup {
            MainMenuView(game: game)
        }
    }
}
