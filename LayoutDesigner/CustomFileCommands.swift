//
//  CustomFileCommands.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 11.07.2022.
//

import Foundation
import SwiftUI

struct CustomFileCommands: Commands {
    @ObservedObject var editor: EditorViewModel
    @State var menuUpdater: Bool = false

    var body: some Commands {
        CommandGroup(replacing: CommandGroupPlacement.newItem) {
            Button("Open adventure".localized()) {
                openAdventure()
            }

            Button("Open layout".localized()) {
                openLayout()
            }

            Button("Generate layout".localized()) {
                generateLayout()
            }.disabled(editor.adventurePrototype == nil)

            Button("Save layout".localized()) {
                saveLayout()
            }.disabled(editor.adventureEngine == nil || EditorStorageService.getLayoutPath() == nil)

            Button("Save layout as".localized()) {
                saveLayoutAs()
            }.disabled(editor.adventureEngine == nil)
        }
    }

    private func openAdventure() {
        NSOpenPanel.runOpenJsonPanel {
            let path = $0.url?.absoluteString
            editor.loadAdventure(path)
        }
    }

    private func openLayout() {
        NSOpenPanel.runOpenJsonPanel {
            let path = $0.url?.absoluteString
            editor.loadLayout(path)
        }
    }

    private func generateLayout() {
        guard let prototype = editor.adventurePrototype else { return }
        let layout = AdventureLayout.autolayout(for: prototype)
        editor.applyLayout(layout)
    }

    private func saveLayout() {
        guard let path = EditorStorageService.getLayoutPath() else {
            return
        }
        saveLayout(into: path)
    }

    private func saveLayoutAs() {
        NSSavePanel.runSaveJsonPanel { panel in
            guard let path = panel.url?.absoluteString else { return }
            saveLayout(into: path)
        }
    }

    private func saveLayout(into path: String) {
        guard let layout = editor.currentStateLayout() else {
            return
        }

        let protoLayout = AdventureLayoutPrototype(layout)
        JSONEncoder.encodeLayout(protoLayout, into: path)
        EditorStorageService.setLayoutPath(path)
        menuUpdater.toggle()
    }
}
