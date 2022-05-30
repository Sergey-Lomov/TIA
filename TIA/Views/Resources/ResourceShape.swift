//
//  ResourceShape.swift
//  TIA
//
//  Created by Serhii.Lomov on 25.04.2022.
//

import Foundation
import SwiftUI

struct ResourceShape: Shape {
    let type: ResourceType
    
    func path(in rect: CGRect) -> Path {
        let halfSize = rect.size.half
        var transform = CGAffineTransform(scaleX: halfSize.width, y: halfSize.height)
        transform = transform.translatedBy(x: 1, y: 1)
        
        switch type {
        case .despair:
            return Path.despair().applying(transform)
        case .anger:
            return Path.anger().applying(transform)
        case .yearning:
            return Path.yearning().applying(transform)
        case .inspiration:
            return Path()
        case .fun:
            return Path()
        case .love:
            return Path()
        }
    }
}
