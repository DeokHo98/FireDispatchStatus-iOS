//
//  FireDispatchStatusAppApp.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/20/24.
//

import SwiftUI
import ComposableArchitecture

@main
struct FireDispatchStatusAppApp: App {
    var body: some Scene {
        WindowGroup {
            let store = Store(initialState: FireDispatchFeature.State()) {
                FireDispatchFeature()
            }
            FireDispatchView(store: store)
        }
    }
}
