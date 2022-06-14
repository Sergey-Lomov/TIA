//
//  WorldPickerView.swift
//  TIA
//
//  Created by Serhii.Lomov on 06.04.2022.
//

import SwiftUI

struct WorldPickerView: View {
    @StateObject var scenario: Scenario
    
    var body: some View {
        CenteredGeometryReader {
            DropShape()
                .fill(Color.softBlack)
            DropShape()
                .fill(Color.softWhite)
                .rotationEffect(.radians(Double.pi))
            
            let themes = AdventureTheme.allCases
            ForEach(themes.indices, id: \.self) { index in
                ThemeAdventuresView(scenario: scenario, theme: themes[index])
            }
        }
    }
}

struct WorldPickerView_Previews: PreviewProvider {
    static var previews: some View {
        let scenario = GameState().scenario
        Group {
            WorldPickerView(scenario: scenario)
                .frame(width: 200, height: 200)
        }
    }
}

struct ThemeAdventuresView: View {
    @ObservedObject var scenario: Scenario
    let theme: AdventureTheme
    
    var body: some View {
        CenteredGeometryReader { geometry in
            let adventures = scenario.adventures[theme] ?? []
            ForEach(adventures.indices, id: \.self) { index in
                let adventure = adventures[index]
                AdventureIconWrapper(adventure: adventure)
                    .frame(geometry: geometry)
            }
        }
    }
}

struct DropShape: Shape {
    private let cirleControlCoefficient: CGFloat = 0.66666
    
    // TODO: Think of changing calculations to constants or using new 'arc' func in BezierCurve
    func path(in rect: CGRect) -> Path {
        
        let center = CGPoint(x:rect.midX, y: rect.midY)
        let bottom = CGPoint(x: rect.midX, y: rect.height)
        let top = CGPoint(x: rect.midX, y: 0)
        
        // Draw circle border
        
        let controlX = -1 * rect.width * ( cirleControlCoefficient - 0.5)
        let control1 = CGPoint(x: controlX, y: rect.height)
        let control2 = CGPoint(x: controlX, y: 0)
        
        var path = Path()
        path.move(to: bottom)
        path.addCurve(to: top, control1: control1, control2: control2)
        
        // Draw separator
        let smallControlX = rect.midX * cirleControlCoefficient
        let control3 = CGPoint(x: rect.midX + smallControlX, y: 0)
        let control4 = CGPoint(x: rect.midX  + smallControlX, y: rect.midY)
        let control5 = CGPoint(x: rect.midX - smallControlX, y: rect.midY)
        let control6 = CGPoint(x: rect.midX - smallControlX, y: rect.height)
        
        path.addCurve(to: center, control1: control3, control2: control4)
        path.addCurve(to: bottom, control1: control5, control2: control6)
        return path
    }
}
