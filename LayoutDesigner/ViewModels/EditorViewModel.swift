//
//  EditorViewModel.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 10.07.2022.
//

import Foundation

class EditorViewModel: ObservableObject {
    @Published var screenSize: ScreenSize = .iPhone12Pro
    @Published var adventurePrototype: AdventurePrototype?
    @Published var adventureEngine: AdventureEngine?

    var layout: AdventureLayout?

    func applyLayout(_ layout: AdventureLayout) {
        guard let prototype = adventurePrototype else { return }
        self.layout = layout
        adventureEngine = AdventureEngine(prototype: prototype, layoutProvider: self, menuItems: [.exit, .restart])
    }
}

extension EditorViewModel: AdventureLayoutProvider {
    func getLayout(_ adventure: AdventurePrototype) -> AdventureLayout {
        if let layout = layout { return layout }
        return AdventureLayout.autolayout(for: adventure)
    }
}
