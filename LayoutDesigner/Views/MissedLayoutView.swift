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
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false
                panel.allowedContentTypes = [.json]
                if panel.runModal() == .OK {
                    handleFileSelection(panel: panel)
                }
            }
            Button("Generate layout".localized()) {
                handleLayoutGeneration()
            }
        }
    }

    func handleFileSelection(panel: NSOpenPanel) {
        let path = panel.url?.absoluteString ?? ""
        let layoutPrototype = JSONDecoder.decodeLayout(path)
        if let layoutPrototype = layoutPrototype {
            let layout = AdventureLayout(layoutPrototype)
            editorModel.applyLayout(layout)
        } else {
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
