//
//  EditorViewModel.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 10.07.2022.
//

import Foundation

class EditorViewModel: ObservableObject {
    @Published var screenSize: ScreenSize
    @Published var adventurePrototype: AdventurePrototype?
    @Published var adventureEngine: AdventureEngine?

    var layout: AdventureLayout?

    init () {
        screenSize = EditorStorageService.getScreenSize() ?? .iPhone12
        EditorStorageService.shared.startSink(.screenSize, publisher: $screenSize)

        guard let adventurePath = EditorStorageService.getAdventurePath(),
              let protoAdventure = JSONDecoder.decodeAdventure(adventurePath) else {
            return
        }
        self.adventurePrototype = protoAdventure

        guard let layoutPath = EditorStorageService.getLayoutPath(),
              let protoLayout = JSONDecoder.decodeLayout(layoutPath) else {
            return
        }
        let layout = AdventureLayout(protoLayout)
        self.applyLayout(layout)
    }

    func applyLayout(_ layout: AdventureLayout) {
        guard let prototype = adventurePrototype else { return }
        self.layout = layout
        adventureEngine = AdventureEngine(prototype: prototype, layoutProvider: self, menuItems: [.exit, .restart])
    }

    func loadAdventure(_ path: String?) {
        guard let path = path else {
            adventurePrototype = nil
            return
        }
        adventurePrototype = JSONDecoder.decodeAdventure(path)
        if adventurePrototype != nil {
            EditorStorageService.setAdventurePath(path)
        }
    }

    func loadLayout(_ path: String?) {
        guard let path = path,
              let layoutPrototype = JSONDecoder.decodeLayout(path) else {
            layout = nil
            adventureEngine = nil
            return
        }

        applyLayout(AdventureLayout(layoutPrototype))
        EditorStorageService.setLayoutPath(path)
    }
}

extension EditorViewModel: AdventureLayoutProvider {
    func getLayout(_ adventure: AdventurePrototype) -> AdventureLayout {
        if let layout = layout { return layout }
        return AdventureLayout.autolayout(for: adventure)
    }
}
