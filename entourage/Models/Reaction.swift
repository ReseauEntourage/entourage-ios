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
struct CompleteReactionsResponse: Codable {
    let userReactions: [UserReaction]

    enum CodingKeys: String, CodingKey {
        case userReactions = "user_reactions"
    }
}

struct UserReaction: Codable {
    let reactionId: Int
    let user: UserLightNeighborhood

    enum CodingKeys: String, CodingKey {
        case reactionId = "reaction_id"
        case user
    }
}

/// Forme plate d'un événement socket `user_reaction_added` / `user_reaction_removed` —
/// distincte de `Reaction` (agrégat compteur) et `UserReaction` (imbrique l'utilisateur complet).
struct ChatReactionEvent: Codable {
    var id: Int
    var reactionId: Int
    var userId: Int
    var chatMessageId: Int

    enum CodingKeys: String, CodingKey {
        case id
        case reactionId = "reaction_id"
        case userId = "user_id"
        case chatMessageId = "chat_message_id"
    }
}
