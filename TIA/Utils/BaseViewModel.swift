//
//  BaseViewModel.swift
//  TIA
//
//  Created by serhii.lomov on 02.07.2022.
//

import Foundation
import Combine

// swiftlint:disable:next final_classes
class BaseViewModel<Model: IdEqutable>: ObservableObject, IdEqutable where Model: ObservableObject {

    @Transpublished var model: Model
    var id: String { model.id }

    init(model: Model) {
        self.model = model
        self._model.publisher = objectWillChange
    }
}

// swiftlint:disable:next final_classes
class PublishingViewModel<Model: IdEqutable, Output>: BaseViewModel<Model> where Model: ObservableObject {
    var publisher: PassthroughSubject<Output, Never>

    init(model: Model, publisher: PassthroughSubject<Output, Never>) {
        self.publisher = publisher
        super.init(model: model)
    }

    func send(_ output: Output) {
        publisher.send(output)
    }
}

typealias IngameViewModel<Model: IdEqutable> = PublishingViewModel<Model, IngameViewEvent> where Model: ObservableObject
