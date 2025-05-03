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
        ZStack {
            Color.yellow
                .edgesIgnoringSafeArea(.all)

            WorldPickerView(model: model)
                .frame(size: Layout.MainMenu.pickerSize)
                .environment(\.cameraService, model.cameraService)

            GeometryReader { geometry in
                let x = geometry.size.width / 2
                let y = geometry.size.height / 4 - Layout.MainMenu.pickerSize / 4
                Text("main_menu_hint")
                    .position(x: x, y: y)
                    .padding(.horizontal, Layout.MainMenu.horizontalInset)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .applyCamera(model.camera)
        .onPreferenceChange(SelectedAdventureKey.self) { descriptor in
            if let descriptor = descriptor {
                model.adventureSelected(descriptor)
            }
        }
        .background(Color.red)
    }
}
