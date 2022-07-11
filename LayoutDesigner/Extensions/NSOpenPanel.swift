//
//  NSOpenPanel.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 11.07.2022.
//

import Foundation
import AppKit

extension NSOpenPanel {
    static func runJsonPanel(_ completion: (NSOpenPanel) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.json]
        if panel.runModal() == .OK {
            completion(panel)
        }
    }
}
