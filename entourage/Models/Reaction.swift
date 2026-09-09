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

    /// Catalogue des réactions disponibles, chargé une fois au login
    /// (`MetadatasService.getMetadatas` → `Metadatas.sharedInstance.parseMetadatas`)
    /// et mis en cache dans `UserDefaults`. Point d'accès unique pour tous les écrans.
    static func stored() -> [ReactionType]? {
        guard let data = UserDefaults.standard.data(forKey: "StoredReactions") else { return nil }
        return try? JSONDecoder().decode([ReactionType].self, from: data)
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
struct ChatReactionEvent: Decodable {
    var id: Int
    var reactionId: Int
    var userId: Int
    var chatMessageId: Int

    private enum CodingKeys: String, CodingKey {
        case id
        case reactionId = "reaction_id"
        case userId = "user_id"
        case chatMessageId = "chat_message_id"
        case chatMessage = "chat_message"
    }
    private enum NestedIdKey: String, CodingKey {
        case id
    }

    init(id: Int, reactionId: Int, userId: Int, chatMessageId: Int) {
        self.id = id
        self.reactionId = reactionId
        self.userId = userId
        self.chatMessageId = chatMessageId
    }

    // `chat_message_id` arrive tantôt à plat, tantôt imbriqué sous `chat_message.id`
    // (constaté en prod côté Android) — on gère les deux formes.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        reactionId = try container.decode(Int.self, forKey: .reactionId)
        userId = try container.decode(Int.self, forKey: .userId)
        if let flatId = try container.decodeIfPresent(Int.self, forKey: .chatMessageId) {
            chatMessageId = flatId
        } else {
            let nested = try container.nestedContainer(keyedBy: NestedIdKey.self, forKey: .chatMessage)
            chatMessageId = try nested.decode(Int.self, forKey: .id)
        }
    }
}
