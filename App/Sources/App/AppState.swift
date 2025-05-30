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

        if (try? keychainService.load()) != nil {
            self.authState = .authenticated
        }
    }

    func exchangeCodeForToken(with code: String) async throws {
        try await verifyAuthentication(using: code)
    }

    func verifyAuthentication(using code: String) async throws {
        do {
            try keychainService.save(GitHubToken(value: code))
            if let username = try await apiClient.fetchUser().name {
                userDefaults.set(username, forKey: "username")
                authState = .authenticated
            } else {
                authState = .error("Could not verify user on GitHub")
            }
        } catch {
            print("Failed to save token to keychain: \(error)")
            authState = .error(error.localizedDescription)
        }
    }

    func createProject(with name: String) {
        let newProject = Project(name: name)
        projects.append(newProject)
    }

    func addRepository(to project: Project, fromGitHubURL urlString: String) async {
        guard let (owner, repo) = parseGitHubURL(urlString) else {
            print("Invalid GitHub URL or missing token")
            return
        }
        do {
            let releases = try await apiClient.fetchReleases(owner: owner, repo: repo)
            let latestTag = releases.first?.tagName
            let repository = Repository(
                id: releases.first?.id ?? Int.random(in: 10000 ... 99999),
                name: repo,
                url: URL(string: urlString)!,
                latestTag: latestTag
            )
            if let index = projects.firstIndex(where: { $0.name == project.name }) {
                projects[index].repositories.append(repository)
            }
        } catch {
            print("Failed to fetch releases: \(error)")
        }
    }

    private func parseGitHubURL(_ urlString: String) -> (String, String)? {
        if let url = URL(string: urlString), url.host == "github.com" {
            let pathComponents = url.path.split(separator: "/")
            if pathComponents.count >= 2 {
                return (String(pathComponents[0]), String(pathComponents[1]))
            }
        } else if urlString.contains("/") {
            let parts = urlString.split(separator: "/")
            if parts.count == 2 {
                return (String(parts[0]), String(parts[1]))
            }
        }
        return nil
    }
}
