//
//  AdventureBackgroundView.swift
//  TIA
//
//  Created by serhii.lomov on 13.07.2022.
//

import SwiftUI

struct AdventureBackgroundView: View {
    @ObservedObject var adventure: AdventureViewModel

    var body: some View {
        adventure.background
            .edgesIgnoringSafeArea(.all)
            .gesture(
                DragGesture()
                    .onChanged {
                        let translation = $0.translation.toPoint().scaled(-1)
                        adventure.cameraDragged(translation)
                    }
                    .onEnded {
                        let translation = $0.translation.toPoint().scaled(-1)
                        adventure.cameraDraggingFinished(translation)
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged {
                        adventure.cameraMagnified($0)
                    }
                    .onEnded {
                        adventure.cameraMagnificationFinished($0)
                    }
            )
    }
}
