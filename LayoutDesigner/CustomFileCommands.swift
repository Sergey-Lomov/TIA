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
        }
    }

    private func openAdventure() {
        NSOpenPanel.runJsonPanel {
            let path = $0.url?.absoluteString
            editor.loadAdventure(path)
        }
    }

    private func openLayout() {
        NSOpenPanel.runJsonPanel {
            let path = $0.url?.absoluteString
            editor.loadLayout(path)
        }
    }

    private func generateLayout() {
        guard let prototype = editor.adventurePrototype else { return }
        let layout = AdventureLayout.autolayout(for: prototype)
        editor.applyLayout(layout)
    }
}
