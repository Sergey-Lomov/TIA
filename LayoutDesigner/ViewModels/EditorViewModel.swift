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
            clearAdventure()
            return
        }

        adventurePrototype = JSONDecoder.decodeAdventure(path)
        if adventurePrototype != nil {
            adventureEngine = nil
            layout = nil
            EditorStorageService.setAdventurePath(path)
            EditorStorageService.clear(.layoutPath)
        } else {
            clearAdventure()
        }
    }

    func clearAdventure() {
        adventureEngine = nil
        adventurePrototype = nil
        layout = nil
        EditorStorageService.clear(.layoutPath)
        EditorStorageService.clear(.adventurePath)
    }

    func loadLayout(_ path: String?) {
        guard let path = path,
              let layoutPrototype = JSONDecoder.decodeLayout(path) else {
            layout = nil
            adventureEngine = nil
            EditorStorageService.clear(.layoutPath)
            return
        }

        applyLayout(AdventureLayout(layoutPrototype))
        EditorStorageService.setLayoutPath(path)
    }

    func currentStateLayout() -> AdventureLayout? {
        guard let adventure = adventureEngine?.adventure else { return nil }
        let initialLayer = adventure.layers.first { $0.type == .initial }
        guard let layer = initialLayer else { return nil }

        let vertices = layer.vertices.reduce(into: [String: CGPoint]()) {
            $0[$1.originId] = $1.point
        }
        typealias EdgesType = [String: AdventureLayout.Controls]
        let edges = layer.edges.reduce(into: EdgesType()) {
            $0[$1.originId] = (p1: $1.curve.p1, p2: $1.curve.p2)
        }

        return AdventureLayout(vertices: vertices, edges: edges)
    }
}

extension EditorViewModel: AdventureLayoutProvider {
    func getLayout(_ adventure: AdventurePrototype) -> AdventureLayout {
        if let layout = layout { return layout }
        return AdventureLayout.autolayout(for: adventure)
    }
}
