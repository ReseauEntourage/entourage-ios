import Foundation

enum ConversationMainDTO {
    case notificationRequest
    case conversation(conversation: Conversation)
    case filter(filter: String)
    case smalltalk(smallTalk: SmallTalk)
}
