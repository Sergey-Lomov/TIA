//
//  CenteredGeometryReader.swift
//  TIA
//
//  Created by Serhii.Lomov on 19.04.2022.
//

import SwiftUI

struct CenteredGeometryReader<Content>: View where Content: View {
    private var content: (GeometryProxy) -> Content

    init(@ViewBuilder content: @escaping (GeometryProxy) -> Content) {
        self.content = content
    }

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = { _ in content() }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                content(geometry)
            }.frame(geometry: geometry)
        }
    }
}
