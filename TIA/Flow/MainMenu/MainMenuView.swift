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
                .environment(\.finalizedAdventure, finalizedAdventure)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .applyCamera(model.camera)
        .onPreferenceChange(SelectedAdventuerePreferenceKey.self) { descriptor in
            if let descriptor = descriptor {
                model.adventureSelected(descriptor)
            }
        }
    }
    
    var finalizedAdventure: AdventureDescriptor? {
        if let adventure = model.game.finalizedAdventure {
            return AdventureDescriptor(adventure)
        } else {
            return nil
        }
    }
}
