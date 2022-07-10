//
//  LayoutDesignerCommands.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 10.07.2022.
//

import SwiftUI

struct LayoutDesignerCommands: Commands {
    @Binding var screenSize: ScreenSize

    var body: some Commands {
        CommandMenu("Screens") {
//            Button("iPhone 12") {
//                editorModel.screenSize = .iPhone12
//            }
//            Button("iPhone 12 Pro") {
//                editorModel.screenSize = .iPhone12Pro
//            }
//            Button("iPhone 12 Pro Max") {
//                editorModel.screenSize = .iPhone12ProMax
//            }
            Picker("ScreenSize", selection: $screenSize) {
                ForEach(ScreenSize.allCases, id: \.self) { value in
                    Text(value.title)
                }
            }
        }
    }
}
