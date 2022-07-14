//
//  MainMenuView.swift
//  TIA
//
//  Created by Serhii.Lomov on 06.04.2022.
//

import SwiftUI

struct SelectedAdventureKey: PreferenceKey {
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
            WorldPickerView(model: model)
                .frame(size: Layout.MainMenu.pickerSize)
                .environment(\.cameraService, model.cameraService)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .applyCamera(model.camera)
        .onPreferenceChange(SelectedAdventureKey.self) { descriptor in
            if let descriptor = descriptor {
                model.adventureSelected(descriptor)
            }
        }
    }
}
