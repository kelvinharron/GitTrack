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
    private let keychainService: KeychainService
    private let userDefaults: UserDefaults
    
    var authState: AuthenticationState = .idle
    
    init(
        apiClient: GitHubAPIClient = .init(),
        keychainService: KeychainService = .init(),
        userDefaults: UserDefaults = .standard
    ) {
        self.apiClient = apiClient
        self.keychainService = keychainService
        self.userDefaults = userDefaults
        
        do {
            try keychainService.load()
            if let username = userDefaults.string(forKey: "username") {
                authState = .authenticated(username)
            }
        } catch {
            authState = .idle
        }
    }
    
    func verifyAuthentication(using token: String) async throws {
        let user = try await apiClient.fetchUser(with: token)
        
        if let username = user.name {
            authState = .authenticated(username)
            try keychainService.save(GitHubToken(value: token))
            userDefaults.set(username, forKey: "username")
        } else {
            authState = .error("User not valid")
        }
    }
}
