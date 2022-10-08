//
//  Bindable.swift
//  productStore
//
//  Created by Minerva Nolasco Espino on 06/10/22.
//

import Foundation

final class Bindable<T> {
    typealias Listener = (T) -> Void
    var listener: Listener?
    var value: T {
        didSet {
            listener?(value)
        }
    }
    init(_ value: T) {
        self.value = value
    }
    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
