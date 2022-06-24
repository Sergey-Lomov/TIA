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
    @State var test = false
    
    var body: some View {
        CenteredGeometryReader { geometry in
//            let rotation = Angle(radians: test ? .pi * 2 : 0)
//            let anchor = UnitPoint(x: 0.5 + 0 / geometry.size.width, y: 0.5 + 50 / geometry.size.height)
//            let scale: CGFloat = test ? 10 : 1
//            let offsetX: CGFloat = test ? 0 : 0
//            let offsetY: CGFloat = test ? -50 : 0
//            let rotation = Angle(radians: test ? 6.28 : 0)
//            let offsetX: CGFloat = test ? 0 : 0
//            let offsetY: CGFloat = test ? -50 : 0
//            let point = CGPoint(x: offsetX, y: offsetY)
//            let unitX = 0.5 + point.x / geometry.size.width
//            let unitY = 0.5 - point.y / geometry.size.height
//            let anchor = UnitPoint(x: 0.5 + 0 / geometry.size.width, y: 0.5 + 50 / geometry.size.height)
//            let scale: CGFloat = test ? 18.7 : 1
            
            ZStack {
                Color.yellow
                    .edgesIgnoringSafeArea(.all)
                
                WorldPickerView(scenario: model.game.scenario)
                    .frame(size: Layout.MainMenu.pickerSize)
                    .environment(\.cameraService, model.cameraService)
            }
//            .rotationEffect(rotation, anchor: anchor)
//            .scaleEffect(scale, anchor: anchor)
//            .offset(point: point)
//            .animation(.easeOut(duration: 3), value: rotation)
            .applyAutostateCamera($model.camera) {
                model.cameraApplied()
            }
            .onPreferenceChange(SelectedAdventuerePreferenceKey.self) { descriptor in
//                test = descriptor != nil
                if let descriptor = descriptor {
                    model.adventureSelected(descriptor)
                }
            }
        }
    }
}
