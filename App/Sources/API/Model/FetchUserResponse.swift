//
//  FetchUserResponse.swift
//  GitTrack
//
//  Created by Kelvin Harron on 20/04/2025.
//

import Foundation

struct FetchUserResponse: Decodable {
    let login: String
    let id: Int
    let url: URL
    let name: String?
    let company: String?
    let email: String?
    let bio: String?
}
