//
//  FireDispatchHeaderFeature.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/27/24.
//

import ComposableArchitecture

@Reducer
struct FireDispatchHeaderFeature {
    @ObservableState
    struct State: Equatable {
        var totalCount: Int
        var inProgressCount: Int
        var endCount: Int
        var deadCount: Int
        var injuredCount: Int
    }
}
