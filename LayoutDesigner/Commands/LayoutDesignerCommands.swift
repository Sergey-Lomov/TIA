//
//  LayoutDesignerCommands.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 10.07.2022.
//

import SwiftUI

struct LayoutDesignerCommands: Commands {
    @Binding var screenSize: ScreenSize

    var body: some Commands {
        CommandMenu("Editor".localized()) {
            // TODO: Fix resources after screen size changing. For now bug here.
            Picker("Screen size".localized(), selection: $screenSize) {
                ForEach(ScreenSize.allCases, id: \.self) { value in
                    Text(value.title)
                }
            }
        }
    }
}
