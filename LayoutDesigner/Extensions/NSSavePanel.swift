//
//  NSSavePanel.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 12.07.2022.
//

import Foundation
import AppKit

extension NSSavePanel {
    static func runSaveJsonPanel(_ completion: (NSSavePanel) -> Void) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.allowsOtherFileTypes = false

        if panel.runModal() == .OK {
            completion(panel)
        }
    }
}
