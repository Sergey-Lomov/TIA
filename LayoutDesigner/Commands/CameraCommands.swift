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
            }.keyboardShortcut("0", modifiers: .command)

            Button("Zoom In".localized()) {
                editor.zoomIn()
            }.keyboardShortcut("+", modifiers: .command)

            Button("Zoom Out".localized()) {
                editor.zoomOut()
            }.keyboardShortcut("-", modifiers: .command)

            Button("Zoom 25%".localized()) {
                editor.zoomTo(0.25)
            }.keyboardShortcut("1", modifiers: .command)

            Button("Zoom 50%".localized()) {
                editor.zoomTo(0.5)
            }.keyboardShortcut("2", modifiers: .command)

            Button("Zoom 100%".localized()) {
                editor.zoomTo(1)
            }.keyboardShortcut("3", modifiers: .command)

            Button("Zoom 200%".localized()) {
                editor.zoomTo(2)
            }.keyboardShortcut("4", modifiers: .command)

            Button("Zoom 400%".localized()) {
                editor.zoomTo(4)
            }.keyboardShortcut("5", modifiers: .command)

            Divider()
        }
    }
}
