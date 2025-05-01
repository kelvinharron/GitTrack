//
//  Endpoint.swift
//  GitTrack
//
//  Created by Kelvin Harron on 13/04/2025.
//

import Foundation

enum Endpoint: String {
    case accessToken
    case releases
    case tags
    case user
    
    static func urlforToken() throws -> URL {
        guard let requestUrl = URL(string: "https://github.com/login/oauth/access_token") else {
            throw APIError.failedToBuildRequest(.accessToken)
        }
        
        return requestUrl
    }
    
    static func url(forOwner owner: String, repo: String, endpoint: Endpoint) throws -> URL {
        guard let requestUrl = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/" + endpoint.rawValue) else {
            throw APIError.failedToBuildRequest(.releases)
        }
        
        return requestUrl
    }
    
    static func urlForUser() throws -> URL {
        guard let requestUrl = URL(string: "https://api.github.com/user") else {
            throw APIError.failedToBuildRequest(.user)
        }
        
        return requestUrl
    }
}
