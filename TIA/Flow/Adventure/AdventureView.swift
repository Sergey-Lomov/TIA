//
//  AdventureView.swift
//  TIA
//
//  Created by Serhii.Lomov on 11.04.2022.
//

import SwiftUI

struct AdventureView: View {
    
    @ObservedObject var adventure: AdventureVisualization
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct AdventureView_Previews: PreviewProvider {
    
    static var previews: some View {
        let adventure = GameState().scenario.adventures[.dark]?.first
        let visualizer = AdventureVisualizer(adventure: adventure!)
        visualizer.updateVisualization()
        return AdventureView(adventure: visualizer.visualization)
    }
}
