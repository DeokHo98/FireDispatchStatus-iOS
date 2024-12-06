//
//  SearchFeature.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/21/24.
//

import SwiftUI
import Combine

@MainActor
struct SearchFeature {
    
    @Observable
    final class State {
        var text = ""
    }
    
    enum Action {
        case textFeildEditing(String)
    }
    
    private(set) var state = State()
    private(set) var delegatePublisher = PassthroughSubject<Delegate, Never>()
    
    func send(_ action: Action) {
        switch action {
        case .textFeildEditing(let text):
            state.text = text
            delegatePublisher.send(.textFiledEditing(text))
        }
    }
}

// MARK: - Delegate

extension SearchFeature {
    enum Delegate {
        case textFiledEditing(String)
    }
}
