//
//  PlayerViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 19.04.2022.
//

import SwiftUI

class PlayerViewModel: ObservableObject {
    @Published var position: PlayerPosition?
    @Published var color: Color
    
    init(color: Color) {
        self.color = color
    }
}
