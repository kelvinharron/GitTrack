//
//  GitHubAPIClient.swift
//  GitTrack
//
//  Created by Kelvin Harron on 19/04/2025.
//

import Foundation

protocol GitHubAPIClientType {
    func fetchAuthToken(authorizationCode: String) async throws -> FetchAccessTokenResponse
    func fetchReleases(owner: String, repo: String) async throws -> [FetchReleaseResponse]
    func fetchTags(owner: String, repo: String) async throws -> [FetchTagResponse]
    func fetchUser() async throws -> FetchUserResponse
}

final class GitHubAPIClient: GitHubAPIClientType {
    private let apiClient: APIClient
    private let keychainService: KeychainService

    init(apiClient: APIClient = .init(), keychainService: KeychainService = .init()) {
        self.apiClient = apiClient
        self.keychainService = keychainService
    }

    func fetchAuthToken(authorizationCode: String) async throws -> FetchAccessTokenResponse {
        let tokenRequestUrl = try Endpoint.urlforToken()

        var request = URLRequest(url: tokenRequestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(authorizationCode)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(buildTokenRequest(from: authorizationCode))

        return try await apiClient.fetch(using: request)
    }

    private func buildTokenRequest(from authorizationCode: String) -> FetchAccessTokenRequest {
        FetchAccessTokenRequest(
            clientId: "",
            clientSecret: "",
            code: authorizationCode,
            redirectUri: "gittrack://callback"
        )
    }

    func fetchReleases(owner: String, repo: String) async throws -> [FetchReleaseResponse] {
        let requestReleasesUrl = try Endpoint.url(forOwner: owner, repo: repo, endpoint: .releases)

        return try await apiClient.fetch(using: makeGetRequest(url: requestReleasesUrl))
    }

    func fetchTags(owner: String, repo: String) async throws -> [FetchTagResponse] {
        let requestReleasesUrl = try Endpoint.url(forOwner: owner, repo: repo, endpoint: .tags)

        return try await apiClient.fetch(using: makeGetRequest(url: requestReleasesUrl))
    }

    func fetchUser() async throws -> FetchUserResponse {
        let userRequestUrl = try Endpoint.urlForUser()

        return try await apiClient.fetch(using: makeGetRequest(url: userRequestUrl))
    }

    private func makeGetRequest(url: URL) throws -> URLRequest {
        let token = try keychainService.load()
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        request.setValue("Bearer \(token.value)", forHTTPHeaderField: "Authorization")
        return request
    }
}
