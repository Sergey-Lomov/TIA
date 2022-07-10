//
//  ScreenSize.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 10.07.2022.
//

import Foundation

enum ScreenSize: Hashable, CaseIterable {

    case iPhone12
    case iPhone12Pro
    case iPhone12ProMax

    var size: CGSize {
        switch self {
        case .iPhone12, .iPhone12Pro:
            return CGSize(width: 400, height: 800)
        case .iPhone12ProMax:
            return CGSize(width: 430, height: 850)
        }
    }

    var title: String {
        switch self {
        case .iPhone12:
            return "iPhone 12"
        case .iPhone12Pro:
            return "iPhone 12 Pro"
        case .iPhone12ProMax:
            return "iPhone 12 Pro Max"
        }
    }
}
