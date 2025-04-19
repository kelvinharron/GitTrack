//
//  APIClient.swift
//  GitTrack
//
//  Created by Kelvin Harron on 13/04/2025.
//

import Foundation
import OSLog

enum APIError: Error, CustomStringConvertible {
    case failedToBuildRequest(owner: String, repo: String)
    case decodeError
    case authError
    case responseError
    case httpUrlResponseError
    case unknownError

    //TODO: improve error handling
    var description: String {
        switch self {
        case .failedToBuildRequest(let owner, let repo):
            "Failed to build request for owner: \(owner), repo: \(repo)"
        case .decodeError:
            "Failed to decode response"
        case .authError:
            "Authentication error"
        case .responseError:
            "Response error"
        case .httpUrlResponseError:
            "HTTP URL response error"
        case .unknownError:
            "Unknown error"
        }
    }
}

final class APIClient {
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    private let logger: Logger

    init(
        urlSession: URLSession = .shared,
        jsonDecoder: JSONDecoder = .init(),
        logger: Logger = Logger(subsystem: "com.kelvinharron.GitTrack", category: "APIClient")
    ) {
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
        self.jsonDecoder.dateDecodingStrategy = .iso8601
        self.logger = logger
    }

    func fetch<T: Decodable>(using request: URLRequest) async throws -> T {
        logger.trace("Executing API request to \(request.url?.description ?? "", privacy: .private)")
        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.httpUrlResponseError
        }

        logger.trace(
            """
            API response for \(request.url?.absoluteString ?? "invalid endpoint")
            Status code: \(httpResponse.statusCode)
            \(httpResponse.printPrettyJSON(from: data) ?? "", privacy: .private)
            """
        )

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
        } catch let error as DecodingError {
            logger.error("DecodingError: \(error.localizedDescription, privacy: .private)")
            if let jsonString = String(data: data, encoding: .utf8) {
                logger.debug("Response JSON: \(jsonString, privacy: .private)")
            }
            throw error
        } catch {
            logger.error("Unexpected decoding error: \(error.localizedDescription, privacy: .private)")
            if let jsonString = String(data: data, encoding: .utf8) {
                logger.debug("Response JSON: \(jsonString, privacy: .private)")
            }
            throw error
        }
    }
}

extension HTTPURLResponse {
    func printPrettyJSON(from data: Data?) -> String? {
        guard let data = data else {
            return nil
        }

        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])

            return String(data: prettyData, encoding: .utf8)
        } catch {
            print("Failed to parse JSON: \(error.localizedDescription)")
            return nil
        }
    }
}
