//
//  AlertState+Ex.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/21/24.
//

import Foundation
import ComposableArchitecture

extension AlertState {
    static func onlyOkButtonAlert(title: String) -> AlertState<Action> {
        AlertState {
            TextState(title)
        } actions: {
            ButtonState {
                TextState("확인")
            }
        }
    }
}
