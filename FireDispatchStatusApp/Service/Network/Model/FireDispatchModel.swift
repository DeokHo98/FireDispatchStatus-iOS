//
//  FireDispatchModel.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/20/24.
//

import Foundation

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
