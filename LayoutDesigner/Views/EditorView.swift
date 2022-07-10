//
//  EditorView.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 05.07.2022.
//

import SwiftUI

struct EditorView: View {
    @ObservedObject var model: EditorViewModel

    var body: some View {
        ZStack {
            if model.adventurePrototype == nil {
                MissedAdventureView(editorModel: model)
            } else {
                if model.adventureEngine == nil {
                    MissedLayouteView(editorModel: model)
                }
            }

            if let adventureModel = adventureViewModel {
                AdventureView(adventure: adventureModel)
            }
        }.frame(size: model.screenSize.size)
    }

    var adventureViewModel: AdventureViewModel? {
        let adventure = model.adventureEngine?.adventure
        let resources = model.adventureEngine?.resources
        let player = model.adventureEngine?.player
        guard let adventure = adventure, let player = player, let resources = resources else {
               return nil
           }

        let cameraService = CameraService(safe: model.screenSize.size, full: model.screenSize.size)
        return .init(adventure,
                     cameraService: cameraService,
                     player: player,
                     resources: resources,
                     listener: model.adventureEngine,
                     eventsSource: model.adventureEngine)
    }
}
