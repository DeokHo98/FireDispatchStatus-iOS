//
//  NetworkService.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/20/24.
//

import Foundation

protocol NetworkServiceDependency {
    func request<T: Codable>(_ request: NetworkRequest) async throws -> T
}

final class NetworkService: NetworkServiceDependency {
    private let baseURL: String
    private let urlSession: URLSession
    
    init(baseURL: NetworkBaseURL, urlSession: URLSession = .shared) {
        self.baseURL = baseURL.rawValue
        self.urlSession = urlSession
    }
    
    func request<T: Decodable>(_ request: NetworkRequest) async throws -> T {
        let url = try createURL(from: request)
        let urlRequest = createURLRequest(from: url, request: request)
        let (data, response) = try await performRequest(urlRequest)
        let validData = try handleHTTPResponse(response, data: data)
        do {
            return try JSONDecoder().decode(T.self, from: validData)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    private func createURL(from request: NetworkRequest) throws -> URL {
        guard let baseURL = baseURL.decryptBaseURL() else {
            throw NetworkError.failedDecryptURL
        }
        guard var urlComponents = URLComponents(string: baseURL + request.path) else {
            throw NetworkError.invalidURL
        }
        urlComponents.queryItems = request.queryItems
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        return url
    }
    
    private func createURLRequest(from url: URL, request: NetworkRequest) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        urlRequest.httpBody = request.body
        return urlRequest
    }
    
    private func performRequest(_ urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        let (data, response) = try await urlSession.data(for: urlRequest)
        return (data, response)
    }
    
    private func handleHTTPResponse(_ response: URLResponse, data: Data) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        switch httpResponse.statusCode {
        case 200...299:
            return data
        default:
            throw NetworkError.serverError(httpResponse.statusCode)
        }
    }
    
}
