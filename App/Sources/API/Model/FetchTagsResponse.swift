//
//  FetchTagsResponse.swift
//  GitTrack
//
//  Created by Kelvin Harron on 19/04/2025.
//

import Foundation

struct FetchTagResponse: Decodable {
    let name: String
    let commit: Commit
    let zipballURL: URL?
    let tarballURL: URL?

    enum CodingKeys: String, CodingKey {
        case name, commit
        case zipballURL = "zipball_url"
        case tarballURL = "tarball_url"
    }

    struct Commit: Decodable {
        let sha: String
        let url: URL
    }
}
