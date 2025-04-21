//
//  KeychainCredential.swift
//  GitTrack
//
//  Created by Kelvin Harron on 21/04/2025.
//

import Foundation

struct GitHubToken {
    static let keychainAccount: String = "github_pat"
    static let keychainService: String = "com.kelvinharron.gittrack"

    let value: String

    init(value: String) {
        self.value = value
    }
}
