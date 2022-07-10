//
//  EditorView.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 05.07.2022.
//

import SwiftUI

struct EditorView: View {
    @ObservedObject var model: EditorViewModel

    var body: some View {
        ZStack {
            Text("Hello, world!")
                .padding()
        }.frame(size: model.screenSize.size)
    }
}
