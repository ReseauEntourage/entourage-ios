//
//  SmallTalksModels.swift
//  entourage
//
//  Created by Clement entourage on 12/05/2025.
//

import Foundation

struct UserSmallTalkRequest: Codable {
    let id: Int?
    let smalltalk_id: Int?
    let uuid_v2: String?
    let match_format: String?
    let match_locality: Bool?
    let match_gender: Bool?
    let match_interest: Bool?
    let created_at: String?
    let matched_at: String?
    let deleted_at: String?

    let user: UserProfile?
    let smalltalk: SmallTalk?
}

struct UserSmallTalkRequestWrapper: Codable {
    let user_smalltalk: UserSmallTalkFields
}

struct UserSmallTalkFields: Codable {
    let match_format: String?
    let match_locality: Bool?
    let match_gender: Bool?
    let user_gender: String?
}

struct UserProfile: Codable {
    let id: Int
    let display_name: String
    let avatar_url: String?
    let community_roles: [String]
}

struct SmallTalk: Codable {
    let id: Int
    let uuid_v2: String
    let type: String?
    let name: String?
    let subname: String?
    let image_url: String?
    let members_count: Int?
    let last_message:LastMessage? = nil
    let number_of_unread_messages: Int?
    let has_personal_post: Bool?
    let members: [UserProfile]
}

extension UserSmallTalkRequest {
    static func empty() -> UserSmallTalkRequest {
        return UserSmallTalkRequest(
            id: nil,
            smalltalk_id: nil,
            uuid_v2: nil,
            match_format: nil,
            match_locality: nil,
            match_gender: nil,
            match_interest: nil,
            created_at: nil,
            matched_at: nil,
            deleted_at: nil,
            user: nil,
            smalltalk: nil
        )
    }
}
