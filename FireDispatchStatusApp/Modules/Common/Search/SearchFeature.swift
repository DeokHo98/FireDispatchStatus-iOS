//
//  SearchFeature.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/21/24.
//

import ComposableArchitecture

@Reducer
struct SearchFeature {
    @ObservableState
    struct State: Equatable {
        var text: String = ""
    }
    
    enum Action {
        case textFeildEditing(String)
        case delegate(Delegate)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .textFeildEditing(let text):
                state.text = text
                return .run { send in
                    await send(.delegate(.textFeildEditing))
                }
            case .delegate:
                return .none
            }
        }
    }
}

extension SearchFeature {
    enum Delegate {
        case textFeildEditing
    }
}
