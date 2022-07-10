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
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false
                panel.allowedContentTypes = [.json]
                if panel.runModal() == .OK {
                    handleFileSelection(panel: panel)
                }
            }
        }
    }

    func handleFileSelection(panel: NSOpenPanel) {
        let path = panel.url?.absoluteString ?? ""
        let prototype = JSONDecoder.decodeAdventure(path)
        if let prototype = prototype {
            editorModel.adventurePrototype = prototype
        } else {
            let fileName = panel.url?.lastPathComponent ?? ""
            message = fileName + " is not valid adventure file".localized()
        }
    }
}
