//
//  GitHubAPIClient.swift
//  GitTrack
//
//  Created by Kelvin Harron on 19/04/2025.
//

import Foundation

protocol GitHubAPIClientType {
    func fetchReleases(
        owner: String,
        repo: String,
        token: String
    ) async throws -> [FetchReleaseResponse]
    func fetchTags(
        owner: String,
        repo: String,
        token: String
    ) async throws -> [FetchTagResponse]
    func fetchUser(
        with token: String
    ) async throws -> FetchUserResponse
}

final class GitHubAPIClient: GitHubAPIClientType {
    private let apiClient: APIClient

    init(apiClient: APIClient = .init()) {
        self.apiClient = apiClient
    }

    func fetchReleases(owner: String, repo: String, token: String) async throws -> [FetchReleaseResponse] {
        let requestReleasesUrl = try Endpoint.url(forOwner: owner, repo: repo, endpoint: .releases)
        return try await apiClient.fetch(using: makeGetRequest(url: requestReleasesUrl, token: token))
    }

    func fetchTags(owner: String, repo: String, token: String) async throws -> [FetchTagResponse] {
        let requestReleasesUrl = try Endpoint.url(forOwner: owner, repo: repo, endpoint: .tags)
        return try await apiClient.fetch(using: makeGetRequest(url: requestReleasesUrl, token: token))
    }

    func fetchUser(with token: String) async throws -> FetchUserResponse {
        let userRequestUrl = try Endpoint.urlForUser()
        return try await apiClient.fetch(using: makeGetRequest(url: userRequestUrl, token: token))
    }

    private func makeGetRequest(url: URL, token: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
