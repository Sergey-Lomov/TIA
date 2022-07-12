//
//  MissedAdventureView.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 05.07.2022.
//

import SwiftUI

struct MissedAdventureView: View {
    @ObservedObject var editorModel: EditorViewModel
    @State var message: String = "No adventure selected".localized()

    var body: some View {
        VStack {
            Text(message)
            Button("Select adventure".localized()) {
                NSOpenPanel.runOpenJsonPanel() {
                    handleFileSelection(panel: $0)
                }
            }
        }
    }

    func handleFileSelection(panel: NSOpenPanel) {
        let path = panel.url?.absoluteString
        editorModel.loadAdventure(path)
        if editorModel.adventurePrototype == nil {
            let fileName = panel.url?.lastPathComponent ?? ""
            message = fileName + " is not valid adventure file".localized()
        }
    }
}
