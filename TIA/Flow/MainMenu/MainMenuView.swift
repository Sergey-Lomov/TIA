//
//  MainMenuView.swift
//  TIA
//
//  Created by Serhii.Lomov on 06.04.2022.
//

import SwiftUI

struct MainMenuView: View {
    
    @ObservedObject var game: GameState
    private let curve = BezierCurve(points: [
        CGPoint(x: 0, y: 0),
        CGPoint(x: 100, y: 0),
        CGPoint(x: 120, y: 100),
        CGPoint(x: 100, y: 100),
    ])
    @State var progress: CGFloat = 0
    
    var body: some View {
        CenteredGeometryReader { geometry in
            
            Color.yellow
            WorldPickerView(scenario: game.scenario)
                .frame(width: 200, height: 200)

            Button("Done dark1") {
                GameEngine.shared.doneCurrentAdventure(theme: .dark)
            }
                .offset(x: 0, y: 150)

            Button("Start dark") {
                GameEngine.shared.startAdventure(theme: .dark, spaceSize: geometry.size)
            }
                .offset(x: 0, y: 180)
        }.edgesIgnoringSafeArea(.all)
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView(game: GameState())
    }
}
