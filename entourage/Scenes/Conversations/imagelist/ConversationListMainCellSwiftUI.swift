import SwiftUI
import Combine

// MARK: - Compatibility Layer for AsyncImage (iOS 14+)
enum AsyncImagePhase {
    case empty
    case success(Image)
    case failure
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    private let url: URL
    private var cancellable: AnyCancellable?

    init(url: URL) {
        self.url = url
        loadImage()
    }

    deinit { cancellable?.cancel() }

    private func loadImage() {
        isLoading = true
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] _ in self?.isLoading = false },
                receiveValue: { [weak self] in
                    self?.image = $0
                    self?.isLoading = false
                }
            )
    }
}

struct LoadableImage<Placeholder: View>: View {
    let url: URL
    let placeholder: (AsyncImagePhase) -> Placeholder
    @StateObject private var loader: ImageLoader

    init(url: URL, @ViewBuilder placeholder: @escaping (AsyncImagePhase) -> Placeholder) {
        self.url = url
        self.placeholder = placeholder
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }

    var body: some View {
        Group {
            if let image = loader.image {
                placeholder(.success(Image(uiImage: image)))
            } else if loader.isLoading {
                placeholder(.empty)
            } else {
                placeholder(.failure)
            }
        }
    }
}

// MARK: - Main View
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
                    LoadableImage(url: url) { phase in
                        switch phase {
                        case .empty: avatarPlaceholder
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure: avatarPlaceholder
                        }
                    }
                } else {
                    avatarPlaceholder
                }
            }
            .frame(width: 50, height: 50)
            .background(Color("Beige"))
            .clipShape(RoundedRectangle(cornerRadius: isEvent ? 10 : 25))

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text(title)
                        .font(.custom("Quicksand-Bold", size: 15))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .layoutPriority(0) // Laisse la priorité à la date

                    Spacer(minLength: 8)

                    if !isEvent && !conversation.createdDateFormatted.isEmpty {
                        Text(conversation.createdDateFormatted)
                            .font(.custom("NunitoSans-Regular", size: 13))
                            .foregroundColor(conversation.hasUnread ? Color("orange_app") : Color("gris_sombre_40"))
                            .lineLimit(1)
                            .layoutPriority(1) // Force la date à rester visible
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

    // MARK: - Properties
    private var isEvent: Bool { conversation.type == "outing" }

    private var title: String {
        if isSmallTalk {
            let filteredMembers = conversation.members?.filter { $0.uid != currentUserId } ?? []
            return filteredMembers.isEmpty ? "Vous" : filteredMembers.compactMap { $0.username }.joined(separator: " • ")
        }
        if let count = conversation.members_count, count > 2, let members = conversation.members {
            let currentUsername = UserDefaults.currentUser?.displayName
            let trimmedNames = members
                .compactMap { $0.username }
                .filter { $0 != currentUsername }
                .prefix(5)
                .map { username in
                    let end = username.index(username.endIndex, offsetBy: -2, limitedBy: username.startIndex) ?? username.startIndex
                    return String(username[..<end]).trimmingCharacters(in: .whitespaces)
                }
            return trimmedNames.joined(separator: ", ")
        }
        return conversation.title ?? ""
    }

    private var detailMessage: String {
        if conversation.imBlocker() { return "message_user_blocked_by_me_list".localized }
        if let imgUrl = conversation.lastChatMessageImageUrl, !imgUrl.isEmpty { return "📷 " + "photo".localized }
        return conversation.getLastMessage ?? ""
    }

    private var detailMessageColor: Color {
        if conversation.imBlocker() { return .red }
        return conversation.hasUnread ? .black : Color("gris_sombre_40")
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
