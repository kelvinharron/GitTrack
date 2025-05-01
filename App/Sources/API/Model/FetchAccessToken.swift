//
//  FetchAccessToken.swift
//  GitTrack
//
//  Created by Kelvin Harron on 30/04/2025.
//

import Foundation

struct FetchAccessTokenRequest: Encodable {
    let clientId: String
    let clientSecret: String
    let code: String
    let redirectUri: String

    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case code
        case redirectUri = "redirect_uri"
    }
}

struct FetchAccessTokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
    }
}
