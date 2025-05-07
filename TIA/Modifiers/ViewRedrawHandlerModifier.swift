//
//  ViewRedrawHandlerModifier.swift
//  TIA
//
//  Created by serhii.lomov on 09.06.2022.
//

import Foundation
import SwiftUI

struct ViewRedrawHandlerModifier: ViewModifier {

    init(handler: @escaping Action) {
        DispatchQueue.main.async {
            handler()
        }
    }

    func body(content: Content) -> some View {
        content
    }
}
