//
//  EditorView.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 05.07.2022.
//

import SwiftUI

struct EditorView: View {
    @ObservedObject var editor: EditorViewModel

    var body: some View {
        ZStack {
            if editor.adventurePrototype == nil {
                MissedAdventureView(editorModel: editor)
            } else {
                if editor.adventureEngine == nil {
                    MissedLayouteView(editorModel: editor)
                }
            }

            if let adventureModel = adventureViewModel {
                AdventureView(adventure: adventureModel)
                    .environmentObject(editor.config)
            }
        }.frame(size: editor.screenSize.size)
    }

    var adventureViewModel: AdventureViewModel? {
        let adventure = editor.adventureEngine?.adventure
        let resources = editor.adventureEngine?.resources
        let player = editor.adventureEngine?.player
        guard let adventure = adventure, let player = player, let resources = resources else {
               return nil
           }

        let cameraService = CameraService(safe: editor.screenSize.size, full: editor.screenSize.size)
        return .init(adventure,
                     cameraService: cameraService,
                     player: player,
                     resources: resources,
                     listener: editor.adventureEngine,
                     eventsSource: editor.adventureEngine,
                     cameraPublisher: editor.cameraPublisher)
    }
}
