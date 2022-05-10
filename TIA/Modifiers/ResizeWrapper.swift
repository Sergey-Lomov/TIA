//
//  ResizeWrapper.swift
//  TIA
//
//  Created by serhii.lomov on 10.05.2022.
//

import SwiftUI

struct ResizeWrapper: AnimatableModifier  {
    
    static private let defaultLengthSteps = 100

    private var from: CGSize
    private var to: CGSize
    private var progress: CGFloat
    private var deltaT: CGFloat
    
    init(from: CGSize, to: CGSize, onFinish: (() -> Void)?, progress: CGFloat, deltaT: CGFloat = 0) {
        self.from = from
        self.to = to
        self.progress = progress
        self.deltaT = deltaT
    }
    
    public var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
        }
    }
    
    func body(content: Content) -> some View {
        CenteredGeometryReader {
            let t = progress - deltaT
            let size = from + (to - from).sca
            content
                .frame()
                .animation(nil, value: point)
        }
    }
    
    private func getPoint(t: CGFloat) -> CGPoint {
        guard !curve.components.isEmpty else { return .zero }
        
        var left = t
        var index = 0
        while index < ratios.count - 1 && ratios[index] < left {
            left -= ratios[index]
            index += 1
        }
        let local = Math.divide(left, ratios[index])
        let curve = curve.components[index]
        return curve.getPoint(t: local)
    }
}
