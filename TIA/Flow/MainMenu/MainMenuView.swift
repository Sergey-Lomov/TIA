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

            VStack(spacing: 0) {
                VStack {
                    Text("main_menu_hint")
                        .padding(.horizontal, Layout.MainMenu.horizontalInset)
                        .font(.custom("ShareTechMono-Regular", size: 20))
                }
                .frame(maxHeight: .infinity)

                WorldPickerView(model: model)
                    .frame(size: Layout.MainMenu.pickerSize)
                    .environment(\.cameraService, model.cameraService)
                    .frame(maxHeight: .infinity)

                Spacer()
                    .frame(maxHeight: .infinity)
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
