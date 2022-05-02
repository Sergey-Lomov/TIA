//
//  PlayerViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 19.04.2022.
//

import SwiftUI
import Combine

class PlayerViewModel: ObservableObject {
    var model: Player
    
    // TODO: Think about changing old data source solution to combine-like solution
    weak var viewModelsProvider: ViewModelsProvider?
    @Published var eye: EyeViewModel
    @Published var color: Color
    
    private var subscriptions: [AnyCancellable] = []
    
    var position: PlayerPosition {
        get { model.position }
        set { model.position = newValue }
    }
    
    init(player: Player, color: Color, movingColor: Color) {
        self.model = player
        self.color = color
        self.eye = EyeViewModel()
        
        let positionSub = model.$position.sink {
            [weak self] position in
            if case .abscent = self?.model.position { return }
            self?.handlePositionUpdate(position)
        }
        subscriptions.append(positionSub)
        
        let eyeStatusSub = eye.$status.sink {
            [weak self] status in
            self?.handleEyeStatusUpdate(status)
        }
        subscriptions.append(eyeStatusSub)
        
        let modelUpdateSub = model.objectWillChange.sink {
            [weak self] _ in
            self?.objectWillChange.send()
        }
        subscriptions.append(modelUpdateSub)
        
        let eyeUpdateSub = eye.objectWillChange.sink {
            [weak self] _ in
            self?.objectWillChange.send()
        }
        subscriptions.append(eyeUpdateSub)
    }
    
    func currentEdgeColor() -> Color {
        guard let edge = position.currnetEdge, let edgeViewModel = viewModelsProvider?.edgeViewModel(for: edge) else {
            return .clear
        }
        
        return edgeViewModel.color
    }
    
    func currentEdgeVertices() -> [VertexViewModel] {
        guard let edge = position.currnetEdge else {
            return []
        }
        
        let from = viewModelsProvider?.vertexViewModel(for: edge.from)
        let to = viewModelsProvider?.vertexViewModel(for: edge.to)
        
        return [from, to].compactMap{ $0 }
    }
    
    private func handlePositionUpdate(_ position: PlayerPosition) {
        switch position {
        case .abscent:
            break
        case .vertex:
            eye.open()
        case .edge(_, let status, _):
            switch status {
            case .compressing:
                eye.compress()
            case .moving:
                break
            case .expanding:
                eye.open()
            }
        }
    }
    
    private func handleEyeStatusUpdate(_ status: EyeStatus) {
        switch status {
        case .state(let state):
            switch state {
            case .compressed:
                model.compressingFinished()
            case .closed:
                break
            case .opened:
                model.expandingFinished()
            }
        case .transiotion:
            break
        }
    }
}
