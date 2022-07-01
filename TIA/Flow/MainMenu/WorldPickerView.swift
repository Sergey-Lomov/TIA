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
            ComplexCurveShape(curve: .yinYangDrop())
                .fill(Color.softBlack)
            ComplexCurveShape(curve: .yinYangDrop())
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

extension ComplexCurve {
    static func yinYangDrop() -> ComplexCurve {
        let outer = BezierCurve.arc(from: .hpi, to: 3 * .hpi, radius: 0.5)
        let inner1 = BezierCurve
            .arc(from: .hpi, to: 3 * .hpi, radius: 0.25)
            .translated(x: 0, y: 0.25)
            .reversed()
        let inner2 = BezierCurve
            .arc(from: -1 * .hpi, to: .hpi, radius: 0.25)
            .translated(x: 0, y: -0.25)
        return .init([outer, inner1, inner2])
    }
}
