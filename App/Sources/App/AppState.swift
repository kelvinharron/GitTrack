//
//  AppState.swift
//  GitTrack
//
//  Created by Kelvin Harron on 19/04/2025.
//

import AuthenticationServices
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
    var projects: [Project] = []
    
    init(
        apiClient: GitHubAPIClient = .init(),
        keychainService: KeychainService = .init(),
        userDefaults: UserDefaults = .standard
    ) {
        self.apiClient = apiClient
        self.keychainService = keychainService
        self.userDefaults = userDefaults
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
