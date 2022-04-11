//
//  MainMenuView.swift
//  TIA
//
//  Created by Serhii.Lomov on 06.04.2022.
//

import SwiftUI

struct MainMenuView: View {
    
    @ObservedObject var game: GameState
    
    var body: some View {
        ZStack() {
            Color.yellow
            WorldPickerView(scenario: game.scenario)
                .frame(width: 200, height: 200)
            Button("Done dark1") {
                withAnimation(.easeIn(duration: 3)) {
                    game.doneCurrentAdventure(theme: .dark)
                }
            }
                .offset(x: 0, y: 150)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView(game: GameState.shared)
    }
}
