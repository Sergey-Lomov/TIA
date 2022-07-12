//
//  MissedLayoutView.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 10.07.2022.
//

import SwiftUI

struct MissedLayouteView: View {
    @ObservedObject var editorModel: EditorViewModel
    @State var message: String = "No layout selected".localized()

    var body: some View {
        VStack {
            Text(message)
            Button("Select layout".localized()) {
                NSOpenPanel.runOpenJsonPanel {
                    handleFileSelection(panel: $0)
                }
            }
            Button("Generate layout".localized()) {
                handleLayoutGeneration()
            }
        }
    }

    func handleFileSelection(panel: NSOpenPanel) {
        let path = panel.url?.absoluteString
        editorModel.loadLayout(path)
        if editorModel.adventureEngine == nil {
            let fileName = panel.url?.lastPathComponent ?? ""
            message = fileName + " is not valid layout file".localized()
        }
    }

    func handleLayoutGeneration() {
        guard let prototype = editorModel.adventurePrototype else { return }
        let layout = AdventureLayout.autolayout(for: prototype)
        editorModel.applyLayout(layout)
    }
}
