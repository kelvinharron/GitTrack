//
//  APIClient.swift
//  GitTrack
//
//  Created by Kelvin Harron on 13/04/2025.
//

import Foundation

enum APIError: Error {
    case failedToBuildRequest(owner: String, repo: String)
    case decodeError
    case authError
    case responseError
    case httpUrlResponseError
    case unknownError
}

final class APIClient {
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    
    init(
        urlSession: URLSession = .shared,
        jsonDecoder: JSONDecoder = .init()
    ) {
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
    }
    
    func fetch<T: Decodable>(using request: URLRequest) async throws -> T {
        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.httpUrlResponseError
        }
        
        switch httpResponse.statusCode {
        case 200 ..< 300:
            return try decode(from: data)
        case 400 ..< 500:
            throw APIError.authError
        default:
            throw APIError.unknownError
        }
    }
    
    private func decode<T: Decodable>(from data: Data) throws -> T {
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodeError
        }
    }
}
