//
//  FetchReleasesResponse.swift
//  GitTrack
//
//  Created by Kelvin Harron on 19/04/2025.
//

import Foundation

struct ReleaseResponse: Decodable {
    let id: Int
    let draft: Bool
    let publishedAt: Date
    let assets: [AssetResponse]
    let prerelease: Bool
    let author: GitHubUser
    let createdAt: Date
    let zipballURL: URL
    let url: URL
    let nodeID: String
    let body: String?
    let targetCommitish: String
    let tarballURL: URL
    let htmlURL: URL
    let assetsURL: URL
    let uploadURL: String
    let tagName: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case id
        case draft
        case publishedAt      = "published_at"
        case assets
        case prerelease
        case author
        case createdAt        = "created_at"
        case zipballURL       = "zipball_url"
        case url
        case nodeID           = "node_id"
        case body
        case targetCommitish  = "target_commitish"
        case tarballURL       = "tarball_url"
        case htmlURL          = "html_url"
        case assetsURL        = "assets_url"
        case uploadURL        = "upload_url"
        case tagName          = "tag_name"
        case name
    }
}

struct AssetResponse: Decodable {
    let id: Int
    let uploader: GitHubUser
    let label: String?
    let state: String
    let createdAt: Date
    let contentType: String
    let url: URL
    let nodeID: String
    let size: Int
    let updatedAt: Date
    let browserDownloadURL: URL
    let name: String
    let downloadCount: Int

    enum CodingKeys: String, CodingKey {
        case id
        case uploader
        case label
        case state
        case createdAt          = "created_at"
        case contentType        = "content_type"
        case url
        case nodeID             = "node_id"
        case size
        case updatedAt          = "updated_at"
        case browserDownloadURL = "browser_download_url"
        case name
        case downloadCount      = "download_count"
    }
}

struct GitHubUser: Decodable {
    let id: Int
    let organizationsURL: URL
    let receivedEventsURL: URL
    let followingURL: String
    let login: String
    let avatarURL: URL
    let url: URL
    let nodeID: String
    let subscriptionsURL: URL
    let reposURL: URL
    let type: String
    let userViewType: String
    let htmlURL: URL
    let eventsURL: String
    let siteAdmin: Bool
    let starredURL: String
    let gistsURL: String
    let gravatarID: String
    let followersURL: URL

    enum CodingKeys: String, CodingKey {
        case id
        case organizationsURL = "organizations_url"
        case receivedEventsURL = "received_events_url"
        case followingURL      = "following_url"
        case login
        case avatarURL         = "avatar_url"
        case url
        case nodeID            = "node_id"
        case subscriptionsURL  = "subscriptions_url"
        case reposURL          = "repos_url"
        case type
        case userViewType      = "user_view_type"
        case htmlURL           = "html_url"
        case eventsURL         = "events_url"
        case siteAdmin         = "site_admin"
        case starredURL        = "starred_url"
        case gistsURL          = "gists_url"
        case gravatarID        = "gravatar_id"
        case followersURL      = "followers_url"
    }
}
