//
//  AppState.swift
//  GitTrack
//
//  Created by Kelvin Harron on 19/04/2025.
//

import AuthenticationServices
import Foundation
import Observation

enum AuthenticationState: Equatable {
    case idle
    case waitingForCode(DeviceResponse)
    case authenticated
    case error(String)
    case expired
    
    static func == (lhs: AuthenticationState, rhs: AuthenticationState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.waitingForCode(let lhsResponse), .waitingForCode(let rhsResponse)):
            return lhsResponse.deviceCode == rhsResponse.deviceCode
        case (.authenticated, .authenticated):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        case (.expired, .expired):
            return true
        default:
            return false
        }
    }
}

@Observable
final class AppState {
    private let apiClient: GitHubAPIClient
    private let keychainService: KeychainService
    private let userDefaults: UserDefaults
    
    var authState: AuthenticationState = .idle
    var projects: [Project] = []
    var userName: String? {
        userDefaults.string(forKey: "username")
    }
    
    init(
        apiClient: GitHubAPIClient = .init(),
        keychainService: KeychainService = .init(),
        userDefaults: UserDefaults = .standard
    ) {
        self.apiClient = apiClient
        self.keychainService = keychainService
        self.userDefaults = userDefaults
    }
    
    func exchangeCodeForToken(with code: String) async throws {
        try await verifyAuthentication(using: code)
    }
    
    func verifyAuthentication(using code: String) async throws {
        let user = try await apiClient.fetchUser(with: code)
        
        if let username = user.name {
            authState = .authenticated
//            try keychainService.save(GitHubToken(value: t))
            userDefaults.set(username, forKey: "username")
        } else {
            authState = .error("User not valid")
        }
    }
    
    func createProject(with name: String) {
        let newProject = Project(name: name)
        projects.append(newProject)
    }
    
    func addRepository(to project: Project, repository: Repository) {
        if let index = projects.firstIndex(where: { $0.name == project.name }) {
            projects[index].repositories.append(repository)
        } else {
            print("Could not find project to add repository to")
        }
    }
}
