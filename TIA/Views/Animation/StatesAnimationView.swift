//
//  StatesAnimationView.swift
//  TIA
//
//  Created by Serhii.Lomov on 20.04.2022.
//

import SwiftUI

struct StatesAnimationView<Content>: View, Animatable where Content: View & Animatable {

    typealias State = AnimationState<Content.AnimatableData>
    typealias StatesContainer = AnimationStatesContainer<Content.AnimatableData>
    
    private var content: Content
    private var states: StatesContainer
    private var progress: CGFloat = 0 {
        didSet { content.animatableData = states.valueFor(progress) }
    }
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    init(content: Content, states: [State])
    {
        self.content = content
        self.states = StatesContainer(states: states)
    }
    
    var body: some View {
        content
    }
}
