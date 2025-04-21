//
//  AppState.swift
//  GitTrack
//
//  Created by Kelvin Harron on 19/04/2025.
//

import Foundation
import Observation

enum AuthenticationState {
    case idle
    case authenticated(String)
    case error(String)
    case expired
}

@Observable
final class AppState {
    private let apiClient: GitHubAPIClient
    
    var authState: AuthenticationState = .idle
    
    init(apiClient: GitHubAPIClient = .init()) {
        self.apiClient = apiClient
    }
    
    func verifyAuthentication(using token: String) async throws {
        let user = try await apiClient.fetchUser(with: token)
        
        if let username = user.name {
            authState = .authenticated(username)
        } else {
            authState = .error("User not valid")
        }
    }
}
