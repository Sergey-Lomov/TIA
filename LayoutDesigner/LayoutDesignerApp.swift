//
//  LayoutDesignerApp.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 05.07.2022.
//

import SwiftUI

@main
struct LayoutDesignerApp: App {
    @ObservedObject var editorModel = EditorViewModel()

    var body: some Scene {
        WindowGroup {
            EditorView(model: editorModel)
        }.commands {
            LayoutDesignerCommands(screenSize: $editorModel.screenSize)
        }
    }
}
