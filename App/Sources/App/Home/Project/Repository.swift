//
//  Repository.swift
//  GitTrack
//
//  Created by Kelvin Harron on 26/04/2025.
//

import Foundation

struct Repository: Identifiable, Hashable {
    let id: Int
    let name: String
    let url: URL
    var latestTag: String?

    init(with response: FetchReleaseResponse) {
        self.id = response.id
        self.name = response.name
        self.url = response.url
    }

    init(id: Int, name: String, url: URL, latestTag: String?) {
        self.id = id
        self.name = name
        self.url = url
        self.latestTag = latestTag
    }
}
