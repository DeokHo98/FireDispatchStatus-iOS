//
//  FireDispatchModel.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/20/24.
//

import SwiftUI

struct FireDispatchModel: Codable, Equatable {
    var deadNum: Int
    var date: String
    var state: String
    var sidoOvrNum: String
    var injuryNum: Int
    var address: String
    var centerName: String

    enum CodingKeys: String, CodingKey {
        case deadNum
        case date
        case state
        case sidoOvrNum
        case injuryNum
        case address
        case centerName
    }
}

extension FireDispatchModel {
    var stateBackGroundColor: Color {
        if state.contains("오인") {
            return .gray
        } else if state.contains("잔불") {
            return Color(red: 1.0, green: 0.6, blue: 0.0)
        } else if state.contains("접수") {
            return Color(red: 0.4, green: 0.2, blue: 0.1)
        } else if state.contains("출동") {
            return Color(red: 1.0, green: 0.0, blue: 0.0)
        } else if state.contains("도착") {
            return .blue
        } else if state.contains("귀소") {
            return .green
        } else {
            return .black
        }
    }
}
