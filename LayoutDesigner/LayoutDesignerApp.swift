//
//  LayoutDesignerApp.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 05.07.2022.
//

import SwiftUI

@main
struct LayoutDesignerApp: App {
    @ObservedObject var editor = EditorViewModel()

    var body: some Scene {
        WindowGroup {
            EditorView(editor: editor)
        }.commands {
            CustomFileCommands(editor: editor)
            CameraCommands(editor: editor)
            LayoutDesignerCommands(screenSize: $editor.screenSize)
        }
    }
}
