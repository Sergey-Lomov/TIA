//
//  MainMenuView.swift
//  TIA
//
//  Created by Serhii.Lomov on 06.04.2022.
//

import SwiftUI

struct SelectedAdventuerePreferenceKey: PreferenceKey {
    static var defaultValue: AdventureDescriptor?

    static func reduce(value: inout AdventureDescriptor?, nextValue: () -> AdventureDescriptor?) {
        value = nextValue() ?? value
    }
}

struct MainMenuView: View {
    
    @ObservedObject var model: MainMenuViewModel
    
    var body: some View {
        ZStack() {
            Color.yellow
                .edgesIgnoringSafeArea(.all)
            
            WorldPickerView(scenario: model.game.scenario)
                .frame(size: Layout.MainMenu.pickerSize)
//
//            Button("Done dark1") {
//                GameEngine.shared.doneCurrentAdventure(theme: .dark)
//            }.offset(x: 0, y: 150)
//
//            Button("Start dark") {
//                let descriptor = AdventureDescriptor(id: "dark1", index: 1, theme: .dark)
//                descriptor.state = .planed
//                GameEngine.shared.startAdventure(descriptor)
//            }.offset(x: 0, y: 180)
        }
        .applyCamera(model.camera) {
            model.cameraApplied()
        }
        .onPreferenceChange(SelectedAdventuerePreferenceKey.self) { descriptor in
            if let descriptor = descriptor {
                model.adventureSelected(descriptor)
            }
        }
    }
}
