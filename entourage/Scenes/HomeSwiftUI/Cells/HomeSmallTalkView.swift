import SwiftUI

struct HomeSmallTalkView: View {
    let userRequests: [UserSmallTalkRequest]
    let onSmallTalkClick: (() -> Void)?
    let onSmallTalkConversationClick: ((UserSmallTalkRequest) -> Void)?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                if userRequests.count < 3 {
                    // Create cell
                    HomeSmallTalkCreateView(onSmallTalkClick: onSmallTalkClick)
                }
                ForEach(userRequests, id: \.id) { request in
                    if let status = request.status, status == "pending" {
                        // Waiting cell
                        HomeSmallTalkWaitingView()
                    } else {
                        // Discussion cell
                        HomeSmallTalkDiscussionView(request: request, onSmallTalkConversationClick: onSmallTalkConversationClick)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 160)
    }
}

struct HomeSmallTalkCreateView: View {
    let onSmallTalkClick: (() -> Void)?

    var body: some View {
        Button(action: {
            onSmallTalkClick?()
        }) {
            ZStack(alignment: .leading) {
                LinearGradient(
                    gradient: Gradient(colors: [Color("appOrange"), Color("appOrangeLight")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text("home_v2_small_talk_card_title".localized)
                        .font(.custom("NunitoSans-Bold", size: 18))
                        .foregroundColor(.white)

                    Text("home_v2_small_talk_card_subtitle".localized)
                        .font(.custom("NunitoSans-Regular", size: 14))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    Text("home_v2_small_talk_card_button".localized)
                        .font(.custom("NunitoSans-Bold", size: 14))
                        .foregroundColor(Color("appOrange"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(20)
                }
                .padding(20)
            }
            .frame(width: UIScreen.main.bounds.width * 0.99, height: 160)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HomeSmallTalkWaitingView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                gradient: Gradient(colors: [Color("appOrange"), Color("appOrangeLight")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 12) {
                Text("small_talk_title_waiting".localized)
                    .font(.custom("NunitoSans-Bold", size: 18))
                    .foregroundColor(.white)

                Text("small_talk_subtitle_waiting".localized)
                    .font(.custom("NunitoSans-Regular", size: 14))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            .padding(20)
        }
        .frame(width: UIScreen.main.bounds.width * 0.99, height: 160)
        .cornerRadius(12)
    }
}

struct HomeSmallTalkDiscussionView: View {
    let request: UserSmallTalkRequest
    let onSmallTalkConversationClick: ((UserSmallTalkRequest) -> Void)?

    var filteredMembers: [Member] {
        var members = request.smalltalk?.members ?? []
        if let currentSid = UserDefaults.currentUser?.sid {
            if let index = members.firstIndex(where: { $0.id == currentSid }) {
                members.remove(at: index)
            }
        }
        return members
    }

    var subtitleText: String {
        return filteredMembers.map { $0.display_name }.joined(separator: ", ")
    }

    var body: some View {
        Button(action: {
            onSmallTalkConversationClick?(request)
        }) {
            ZStack(alignment: .leading) {
                Color.white

                VStack(alignment: .leading, spacing: 8) {
                    // Avatars overlapping
                    HStack(spacing: -12) {
                        let avatarsToDisplay = Array(filteredMembers.prefix(4))
                        ForEach(avatarsToDisplay.indices, id: \.self) { index in
                            let member = avatarsToDisplay[index]
                            AsyncImage(url: URL(string: member.avatar_url ?? "")) { phase in
                                if let image = phase.image {
                                    image.resizable()
                                } else if phase.error != nil {
                                    Image("placeholder_user").resizable()
                                } else {
                                    Color.gray.opacity(0.3)
                                }
                            }
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .zIndex(Double(avatarsToDisplay.count - index))
                        }
                    }
                    .padding(.bottom, 4)

                    Text("small_talk_title_conversation".localized)
                        .font(.custom("NunitoSans-Bold", size: 18))
                        .foregroundColor(Color("appBlack"))

                    Text(subtitleText)
                        .font(.custom("NunitoSans-Regular", size: 15))
                        .foregroundColor(Color("appBlack"))
                        .lineLimit(1)

                    if let unread = request.number_of_unread_messages, unread > 0 {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color("appOrange"))
                                .frame(width: 8, height: 8)
                            Text(unread == 1 ? "\(unread) \("title_new_message".localized)" : "\(unread) \("title_new_message_plural".localized)")
                                .font(.custom("NunitoSans-Regular", size: 13))
                                .foregroundColor(Color("appOrange"))
                        }
                    }
                }
                .padding(20)
            }
            .frame(width: UIScreen.main.bounds.width * 0.99, height: 160)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("appBeige"), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
