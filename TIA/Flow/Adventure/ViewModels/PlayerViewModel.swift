//
//  PlayerViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 19.04.2022.
//

import SwiftUI
import Combine

final class PlayerViewModel: BaseViewModel<Player> {

    weak var viewModelsProvider: ViewModelsProvider?
    @Transpublished var eye: EyeViewModel
    @Published var color: Color

    private var subscriptions: [AnyCancellable] = []

    var position: PlayerPosition { model.position }
    var metastate: PlayerMetastate { model.metastate }

    init(player: Player, color: Color, movingColor: Color) {

        self.color = color
        self.eye = EyeViewModel()
        super.init(model: player)

        self._eye.publisher = objectWillChange

        subscriptions.sink(model.$position) { [weak self] position in
            if case .abscent = self?.model.position { return }
            self?.handlePositionUpdate(position)
        }

        subscriptions.sink(eye.$status) { [weak self] status in
            self?.handleEyeStatusUpdate(status)
        }
    }

    func currentEdgeColor() -> Color {
        guard let edge = position.currentEdge, let edgeViewModel = viewModelsProvider?.edgeViewModel(for: edge) else {
            return .clear
        }

        return edgeViewModel.color
    }

    func currentEdgeVertices() -> [VertexViewModel] {
        guard let edge = position.currentEdge else {
            return []
        }

        let from = viewModelsProvider?.vertexViewModel(for: edge.from)
        let to = viewModelsProvider?.vertexViewModel(for: edge.to)

        return [from, to].compactMap { $0 }
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
