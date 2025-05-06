//
//  Project.swift
//  GitTrack
//
//  Created by Kelvin Harron on 26/04/2025.
//

import SwiftUI

struct Project: Hashable, Identifiable {
    var id: String { name }
    let name: String
    var repositories: [Repository]
    
    init(name: String, repositories: [Repository] = []) {
        self.name = name
        self.repositories = repositories
    }
}
