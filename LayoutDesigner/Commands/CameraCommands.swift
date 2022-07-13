//
//  CameraCommands.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 14.07.2022.
//

import Foundation
import SwiftUI

struct CameraCommands: Commands {
    var editor: EditorViewModel

    var body: some Commands {
        CommandGroup(replacing: CommandGroupPlacement.toolbar) {
            Button("Reset transforms".localized()) {
                editor.resetCamera()
            }

            Button("Zoom In".localized()) {
                editor.zoomIn()
            }

            Button("Zoom Out".localized()) {
                editor.zoomOut()
            }

            Button("Zoom 25%".localized()) {
                editor.zoomTo(0.25)
            }

            Button("Zoom 50%".localized()) {
                editor.zoomTo(0.5)
            }

            Button("Zoom 100%".localized()) {
                editor.zoomTo(1)
            }

            Button("Zoom 200%".localized()) {
                editor.zoomTo(2)
            }

            Button("Zoom 400%".localized()) {
                editor.zoomTo(4)
            }

            Divider()
        }
    }
}
