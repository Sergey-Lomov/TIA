//
//  AdventureView.swift
//  TIA
//
//  Created by Serhii.Lomov on 11.04.2022.
//

import SwiftUI
import Combine

struct AdventureView: View {

    @StateObject var adventure: AdventureViewModel
//    @State private var curve = BezierCurve(points: [
//        CGPoint(x: 0, y: -0.1),
//        CGPoint(x: 0, y: 0.1),
//        CGPoint(x: -0.25, y: -0.05),
//        CGPoint(x: -0.25, y: 0.15),
//    ]
    
    var body: some View {
        ZStack {
            adventure.background
                .edgesIgnoringSafeArea(.all)

            ForEach(adventure.edges, id:\.model.id) { edge in
                EdgeWrapper(edge: edge)
            }

            ForEach(adventure.vertices, id:\.model.id) { vertex in
                VertexWrapper(vertex: vertex)
            }
            
            PlayerView(player: adventure.player)
        }
        .onAppear {
            adventure.viewInitCompleted()
        }
//        VStack {
//           SingleCurveShape(curve: curve)
//                .stroke(lineWidth: 4)
//                .foregroundColor(.blue)
//                .frame(width:200, height: 200)
//                .animation(.linear(duration: 2))
//       }
//        .frame(width:400, height: 400)
//       .onTapGesture {
//           self.curve = self.curve.selfMirroredCurve()
//       }
    }
}

struct AdventureView_Previews: PreviewProvider {
    
    static var previews: some View {
        let descriptor = GameState().scenario.adventures[.dark]?.first
        let layout = AdventureLayout.random(for: descriptor!)
        let adventure = ScenarioService.shared.adventureFor(descriptor!, layout: layout)
        
        let viewModel = AdventureViewModel(
            adventure,
            listener: GameEngine.shared.adventureEngine,
            eventsSource: GameEngine.shared.adventureEngine)
        return AdventureView(adventure: viewModel)
    }
}
