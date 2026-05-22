import Foundation
import Combine
import SwiftUI

class ConversationsViewModel: ObservableObject {
    @Published var dataSource: [ConversationMainDTO] = []
    @Published var notificationsDisabled: Bool = false
    @Published var selectedFilter: String = "event_conv_filter_all".localized
    @Published var isFetching = false

    var isLastPage = false
    var currentPage = 1
    let perPage = 25

    init() {
        checkNotificationStatus()

        NotificationCenter.default.addObserver(self, selector: #selector(updateFilterSmallTalk), name: NSNotification.Name(kNotificationMessagesUpdateSmallTalkFilter), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func updateFilterSmallTalk() {
        self.selectedFilter = "event_conv_filter_smalltalks".localized
        self.loadConversations(reset: true)
    }

    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationsDisabled = settings.authorizationStatus != .authorized
                // Reload DTO if needed to show/hide the notif cell
                self.loadConversations(reset: true)
            }
        }
    }

    func onFilterClick(filter: String) {
        self.selectedFilter = filter
        loadConversations(reset: true)
    }

    private func membershipTypeParam() -> String? {
        switch selectedFilter {
        case "event_conv_filter_discussions".localized:
            return "Conversation"
        case "event_conv_filter_events".localized:
            return "Outing"
        case "event_conv_filter_smalltalks".localized:
            return "Smalltalk"
        default:
            return nil
        }
    }

    func loadConversations(reset: Bool) {
        guard !isFetching else { return }
        isFetching = true

        if reset {
            currentPage = 1
            isLastPage = false
            DispatchQueue.main.async {
                self.dataSource.removeAll()
                self.dataSource.append(.filter(filter: ""))
                if self.notificationsDisabled {
                    self.dataSource.append(.notificationRequest)
                }
            }
        }

        if selectedFilter == "event_conv_filter_smalltalks".localized {
            SmallTalkService.listSmallTalks { [weak self] smallTalks, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isFetching = false
                    guard let smallTalks = smallTalks else { return }
                    self.loadDTO(smallTalks: smallTalks, reset: reset)
                }
            }
            return
        }

        let typeParam = membershipTypeParam()
        MessagingService.getConversationMemberships(type: typeParam, page: currentPage, per: perPage) { [weak self] memberships, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isFetching = false
                guard let memberships = memberships else { return }

                self.isLastPage = memberships.count < self.perPage
                let conversations = memberships.map { self.conversation(from: $0) }
                self.loadDTO(conversations: conversations, reset: reset)
                self.currentPage += 1
            }
        }
    }

    func loadMoreIfNeeded(currentItem dto: ConversationMainDTO) {
        guard !isLastPage, !isFetching else { return }
        let thresholdIndex = dataSource.index(dataSource.endIndex, offsetBy: -5)
        if let index = dataSource.firstIndex(where: {
            if case .conversation(let c1) = $0, case .conversation(let c2) = dto { return c1.uid == c2.uid }
            if case .smalltalk(let s1) = $0, case .smalltalk(let s2) = dto { return s1.id == s2.id }
            return false
        }), index >= thresholdIndex {
            loadConversations(reset: false)
        }
    }

    private func loadDTO(conversations: [Conversation], reset: Bool) {
        let newItems = conversations.map { ConversationMainDTO.conversation(conversation: $0) }
        dataSource.append(contentsOf: newItems)
    }

    private func loadDTO(smallTalks: [SmallTalk], reset: Bool) {
        let newItems = smallTalks.map { ConversationMainDTO.smalltalk(smallTalk: $0) }
        dataSource.append(contentsOf: newItems)
    }

    private func conversation(from membership: ConversationMembership) -> Conversation {
        var conv = Conversation()
        conv.uid = membership.id ?? 0
        conv.type = membership.type
        conv.title = membership.name
        conv.subname = membership.subname

        if let lastMessage = membership.lastMessage {
            conv.lastMessage = lastMessage
            conv.lastMessage?.dateStr = membership.lastChatMessageDate
        } else if let dateStr = membership.lastChatMessageDate {
            conv.lastMessage = LastMessage(text: nil, dateStr: dateStr)
        }
        conv.numberUnreadMessages = membership.numberOfUnreadMessages
        conv.members_count = membership.numberOfPeople
        conv.imageUrl = membership.imageUrl
        conv.lastChatMessageImageUrl = membership.lastChatMessageImageUrl

        if (membership.numberOfPeople ?? 0) <= 1 {
            conv.title = "Vous"
        }

        return conv
    }

    func updateUnreadCount(conversationId: Int) {
        if let index = dataSource.firstIndex(where: {
            if case .conversation(let c) = $0 { return c.uid == conversationId }
            return false
        }) {
            if case var .conversation(conv) = dataSource[index] {
                conv.numberUnreadMessages = 0
                dataSource[index] = .conversation(conversation: conv)
            }
        }
    }
}

extension ConversationMainDTO: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .notificationRequest:
            hasher.combine("notificationRequest")
        case .conversation(let conversation):
            hasher.combine(conversation.uid)
        case .filter(let filter):
            hasher.combine("filter")
            hasher.combine(filter)
        case .smalltalk(let smallTalk):
            hasher.combine(smallTalk.id)
        }
    }

    static func == (lhs: ConversationMainDTO, rhs: ConversationMainDTO) -> Bool {
        switch (lhs, rhs) {
        case (.notificationRequest, .notificationRequest):
            return true
        case (.conversation(let lConv), .conversation(let rConv)):
            return lConv.uid == rConv.uid
        case (.filter(let lFilt), .filter(let rFilt)):
            return lFilt == rFilt
        case (.smalltalk(let lSt), .smalltalk(let rSt)):
            return lSt.id == rSt.id
        default:
            return false
        }
    }
}
