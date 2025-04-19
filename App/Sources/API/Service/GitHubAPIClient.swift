//
//  GitHubAPIClient.swift
//  GitTrack
//
//  Created by Kelvin Harron on 19/04/2025.
//

import Foundation

protocol GitHubAPIClientType {
    func fetchReleases(owner: String, repo: String, token: String) async throws -> [ReleaseResponse]
    func fetchTags(owner: String, repo: String, token: String) async throws -> [FetchTagResponse]
}

final class GitHubAPIClient: GitHubAPIClientType {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .init()) {
        self.apiClient = apiClient
    }

    func fetchReleases(owner: String, repo: String, token: String) async throws -> [ReleaseResponse] {
        let request = try buildReleaseRequest(owner: owner, repo: repo, token: token)
        return try await apiClient.fetch(using: request)
    }
    
    
    private func buildReleaseRequest(owner: String, repo: String, token: String) throws -> URLRequest {
        let url = try Endpoint.releases.url(forOwner: owner, repo: repo)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    func fetchTags(owner: String, repo: String, token: String) async throws -> [FetchTagResponse] {
        return [] // TODO: come back to tags
    }
    
}
