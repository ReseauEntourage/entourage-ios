import SwiftUI

struct ConversationListMainCellSwiftUI: View {
    var conversation: Conversation
    var currentUserId: Int?
    var isSmallTalk: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            ZStack {
                if let urlString = isEvent ? conversation.imageUrl : conversation.user?.imageUrl,
                   let url = URL(string: urlString), !urlString.isEmpty {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            avatarPlaceholder
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            avatarPlaceholder
                        @unknown default:
                            avatarPlaceholder
                        }
                    }
                } else {
                    avatarPlaceholder
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(isEvent ? AnyShape(RoundedRectangle(cornerRadius: 10)) : AnyShape(Circle()))
            .background(Color("Beige")) // fallback background

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text(title)
                        .font(.custom("Quicksand-Bold", size: 15))
                        .foregroundColor(.black)
                        .lineLimit(1)

                    Spacer(minLength: 8)

                    if !isEvent, !conversation.hasUnread {
                        Text(conversation.createdDateFormatted)
                            .font(.custom("NunitoSans-Regular", size: 13))
                            .foregroundColor(Color("gris_sombre_40"))
                            .lineLimit(1)
                    } else if !isEvent, conversation.hasUnread {
                        Text(conversation.createdDateFormatted)
                            .font(.custom("NunitoSans-Regular", size: 13))
                            .foregroundColor(Color("orange_app"))
                            .lineLimit(1)
                    }
                }

                if isEvent, let role = conversation.subname {
                    Text(role)
                        .font(.custom("NunitoSans-Regular", size: 11))
                        .foregroundColor(Color("orange_light"))
                        .lineLimit(1)
                } else if !isEvent, let rolesText = conversation.getRolesWithPartnerFormated(), !rolesText.isEmpty {
                    Text(rolesText)
                        .font(.custom("NunitoSans-Regular", size: 11))
                        .foregroundColor(Color("orange_light"))
                        .lineLimit(1)
                }

                HStack(alignment: .top) {
                    Text(detailMessage)
                        .font(conversation.hasUnread ? .custom("NunitoSans-SemiBold", size: 13) : .custom("NunitoSans-Regular", size: 13))
                        .foregroundColor(detailMessageColor)
                        .lineLimit(1)

                    Spacer()

                    if conversation.hasUnread {
                        Text("\(conversation.numberUnreadMessages ?? 0)")
                            .font(.custom("NunitoSans-Bold", size: 12))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color("orange_app"))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
    }

    // Properties

    private var isEvent: Bool {
        return conversation.type == "outing"
    }

    private var title: String {
        if isSmallTalk {
            let filteredMembers = conversation.members?.filter { $0.uid != currentUserId } ?? []
            if filteredMembers.isEmpty {
                return "Vous"
            } else {
                return filteredMembers.compactMap { $0.username }.joined(separator: " • ")
            }
        }

        if let count = conversation.members_count, count > 2, let members = conversation.members {
            let currentUsername = UserDefaults.currentUser?.displayName
            let trimmedNames = members
                .compactMap { $0.username }
                .filter { $0 != currentUsername }
                .prefix(5)
                .map { username -> String in
                    let end = username.index(username.endIndex, offsetBy: -2, limitedBy: username.startIndex) ?? username.startIndex
                    let trimmed = String(username[..<end]).trimmingCharacters(in: .whitespaces)
                    return trimmed
                }
            return trimmedNames.joined(separator: ", ")
        }
        return conversation.title ?? ""
    }

    private var detailMessage: String {
        if conversation.imBlocker() {
            return "message_user_blocked_by_me_list".localized
        }
        if let imgUrl = conversation.lastChatMessageImageUrl, !imgUrl.isEmpty {
            return "📷 " + "photo".localized
        }
        return conversation.getLastMessage ?? ""
    }

    private var detailMessageColor: Color {
        if conversation.imBlocker() {
            return Color.red // .rougeErreur equivalent
        }
        if conversation.hasUnread {
            return .black
        }
        return Color("gris_sombre_40")
    }

    @ViewBuilder
    private var avatarPlaceholder: some View {
        if isEvent {
            Image("ic_placeholder_my_event")
                .resizable()
                .scaledToFit()
                .padding(10)
        } else {
            Image("placeholder_user")
                .resizable()
                .scaledToFill()
        }
    }
}
