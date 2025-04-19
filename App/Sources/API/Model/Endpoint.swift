//
//  Endpoint.swift
//  GitTrack
//
//  Created by Kelvin Harron on 13/04/2025.
//

import Foundation

enum Endpoint: String {
    case releases
    case tags
    
    func url(forOwner owner: String, repo: String) throws -> URL {
        guard let requestUrl = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/" + self.rawValue) else {
            throw APIError.failedToBuildRequest(owner: owner, repo: repo)
        }
        
        return requestUrl
    }
}
