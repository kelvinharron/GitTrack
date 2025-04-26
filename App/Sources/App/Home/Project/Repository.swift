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

    init(with response: FetchReleaseResponse) {
        self.id = response.id
        self.name = response.name
        self.url = response.url
    }
}
