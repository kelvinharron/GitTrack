//
//  GitHubAuthManager.swift
//  GitTrack
//
//  Created by Kelvin Harron on 30/04/2025.
//

import AuthenticationServices
import Foundation

enum GitHubAuthError: Error {
    case invalidURL
    case authenticationError(String)
    case callbackCodeParseError
    case authenticationSessionError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case let .authenticationError(message):
            return "Authentication error: \(message)"
        case .callbackCodeParseError:
            return "Failed to parse code from callback URL"
        case .authenticationSessionError:
            return "Authentication session error"
        }
    }
}

struct DeviceRequest: Encodable {
    let clientId: String = "Ov23liGnA5kEfUkbEXEj"
    let scope: String = "public_repo"

    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case scope
    }
}

struct DeviceResponse: Decodable {
    let deviceCode: String
    let userCode: String
    let verificationURI: URL
    let expiresIn: Int
    let interval: Int

    enum CodingKeys: String, CodingKey {
        case deviceCode = "device_code"
        case userCode = "user_code"
        case verificationURI = "verification_uri"
        case expiresIn = "expires_in"
        case interval
    }
    
    
}

final class GitHubAuthManager: NSObject, ASWebAuthenticationPresentationContextProviding {
    private var authSession: ASWebAuthenticationSession?

    func startDeviceAuthorization() async throws -> DeviceResponse {
        guard let url = URL(string: "https://github.com/login/device/code") else {
            throw GitHubAuthError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(DeviceRequest())

        let (data, _) = try await URLSession.shared.data(for: request)
        if let raw = String(data: data, encoding: .utf8) {
            print("🔎 Raw response from GitHub: \(raw)")
        }
        let response = try JSONDecoder().decode(DeviceResponse.self, from: data)
        return response
    }

    struct PollRequest: Encodable {
        let clientId: String
        let deviceCode: String
        let grantType: String

        enum CodingKeys: String, CodingKey {
            case clientId = "client_id"
            case deviceCode = "device_code"
            case grantType = "grant_type"
        }
    }

    func pollForAccessToken(from response: DeviceResponse) async throws -> String {
        let tokenURL = URL(string: "https://github.com/login/oauth/access_token")!

        var retryCount = 0

        while true {
            var request = URLRequest(url: tokenURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            let pollRequest = PollRequest(
                clientId: "Ov23liGnA5kEfUkbEXEj",
                deviceCode: response.deviceCode,
                grantType: "urn:ietf:params:oauth:grant-type:device_code"
            )

            request.httpBody = try JSONEncoder().encode(pollRequest)

            let (data, _) = try await URLSession.shared.data(for: request)

            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                throw GitHubAuthError.authenticationError("Invalid response from GitHub")
            }

            if let error = json["error"] as? String {
                switch error {

                case "authorization_pending":
                    try await Task.sleep(nanoseconds: UInt64(response.interval) * 1_000_000_000)
                    continue
                case "slow_down":
                    retryCount += 1
                    let delay = response.interval + (retryCount * 5)
                    try await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000_000)
                    continue
                default:
                    throw GitHubAuthError.authenticationError("GitHub error: \(error)")
                }
            }

            if let accessToken = json["access_token"] as? String {
                return accessToken
            } else {
                throw GitHubAuthError.authenticationError("Unknown response from GitHub")
            }
        }
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        NSApplication.shared.windows.first ?? ASPresentationAnchor()
    }
}
