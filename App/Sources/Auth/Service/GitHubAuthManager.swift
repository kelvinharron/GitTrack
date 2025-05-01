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

final class GitHubAuthManager: NSObject, ASWebAuthenticationPresentationContextProviding {
    private var authSession: ASWebAuthenticationSession?

    func startAuthorization(completion: @escaping (Result<String, GitHubAuthError>) -> Void) {
        let clientID = ProcessInfo.processInfo.environment["GITHUB_CLIENT_ID"] ?? ""
        let redirectURI = "gittrack://callback"
        let scope = "public_repo"

        guard let authURL = URL(string:
            "https://github.com/login/oauth/authorize?client_id=\(clientID)&redirect_uri=\(redirectURI)&scope=\(scope)"
        ) else {
            completion(.failure(.invalidURL))
            return
        }

        authSession = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: "gittrack"
        ) { callbackURL, error in
            if let error = error {
                completion(.failure(.authenticationError(error.localizedDescription)))
                return
            }

            guard let callbackURL = callbackURL,
                  let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                  let code = components.queryItems?.first(where: { $0.name == "code" })?.value
            else {
                completion(.failure(.callbackCodeParseError))
                return
            }

            completion(.success(code))
        }

        if let authSession {
            authSession.presentationContextProvider = self
            authSession.prefersEphemeralWebBrowserSession = true
            authSession.start()
        } else {
            completion(.failure(.authenticationSessionError))
        }
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        NSApplication.shared.windows.first ?? ASPresentationAnchor()
    }
}
