//
//  PlayerView.swift
//  TIA
//
//  Created by Serhii.Lomov on 19.04.2022.
//

import SwiftUI

struct PlayerView: View {
    @ObservedObject var player: PlayerViewModel
    
    var body: some View {
        CenteredGeometryReader { geometry in
            if let position = player.position {
                switch position {
                case .edge(let edge, let success):
                    EmptyView()
                case .vertex(let vertex):
                    EyeView(color: .yellow)
                        .offset(point: vertex.point, geometry: geometry)
                        .frame(width: 40, height: 40)
                }
            }
        }
    }
}

//struct PlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayerView()
//    }
//}
