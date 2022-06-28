//
//  WorldPickerView.swift
//  TIA
//
//  Created by Serhii.Lomov on 06.04.2022.
//

import SwiftUI

struct WorldPickerView: View {
    @StateObject var model: MainMenuViewModel
    
    var body: some View {
        CenteredGeometryReader {
            DropShape()
                .fill(Color.softBlack)
            DropShape()
                .fill(Color.softWhite)
                .rotationEffect(.radians(Double.pi))
            
            let themes = AdventureTheme.allCases
            ForEach(themes.indices, id: \.self) { index in
                if let models = model.icons[themes[index]] {
                    ThemeAdventuresView(models: models)
                }
            }
        }
    }
}

struct ThemeAdventuresView: View {
    var models: [AdventureIconViewModel]
    
    var body: some View {
        CenteredGeometryReader { geometry in
            ForEach(models, id: \.id) { model in
                AdventureIconWrapper(model: model)
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
