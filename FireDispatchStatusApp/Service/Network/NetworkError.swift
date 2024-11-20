//
//  NetworkError.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/20/24.
//

import Foundation

enum NetworkError: Error {
    case failedDecryptURL
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(Int)
    case unknown
}
