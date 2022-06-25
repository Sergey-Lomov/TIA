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
        Color.yellow
            .edgesIgnoringSafeArea(.all)
        
        ZStack {
            WorldPickerView(scenario: model.game.scenario)
                .frame(size: Layout.MainMenu.pickerSize)
                .environment(\.cameraService, model.cameraService)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .applyAutostateCamera($model.camera) {
            model.cameraApplied()
        }
        .onPreferenceChange(SelectedAdventuerePreferenceKey.self) { descriptor in
            if let descriptor = descriptor {
                model.adventureSelected(descriptor)
            }
        }
    }
}
