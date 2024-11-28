//
//  FCMModel.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/22/24.
//

import Foundation

struct FCMTokenResponse: Codable, Equatable {
    let success: Bool
    let error: String?

    enum CodingKeys: String, CodingKey {
        case success
        case error
    }
}
