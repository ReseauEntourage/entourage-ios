//
//  Reaction.swift
//  entourage
//
//  Created by Clement entourage on 30/01/2024.
//

import Foundation
struct ReactionType: Codable {
    var id: Int
    var key: String?
    var imageUrl: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case key
        case imageUrl = "image_url"
    }
}
struct Reaction: Codable {
    var reactionId: Int
    var chatMessageId: Int
    var reactionsCount: Int

    private enum CodingKeys: String, CodingKey {
        case reactionId = "reaction_id"
        case chatMessageId = "chat_message_id"
        case reactionsCount = "reactions_count"
    }
}
struct ReactionWrapper: Codable {
    var reactionId: Int?

    private enum CodingKeys: String, CodingKey {
        case reactionId = "reaction_id"
    }
}
