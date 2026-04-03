import SwiftUI
import SDWebImageSwiftUI

struct CellDiscussionSmallTalkView: View {
    var request: UserSmallTalkRequest
    var action: () -> Void

    var members: [ChatSmallTalkMember] {
        var m = request.smalltalk?.members ?? []
        if let currentSid = UserDefaults.currentUser?.sid {
            if let index = m.firstIndex(where: { $0.id == currentSid }) {
                m.remove(at: index)
            }
        }
        return m
    }

    var unreadCountText: String? {
        guard let number = request.number_of_unread_messages, number > 0 else {
            return nil
        }
        if number == 1 {
            return "\(number) \("title_new_message".localized)"
        } else {
            return "\(number) \("title_new_message_plural".localized)"
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Avatars
                ZStack {
                    ForEach(0..<min(members.count, 4), id: \.self) { index in
                        let member = members[index]
                        let offset = CGFloat(index) * 20.0

                        if let urlStr = member.avatar_url, let url = URL(string: urlStr) {
                            WebImage(url: url)
                                .resizable()
                                .placeholder {
                                    Image("placeholder_user")
                                        .resizable()
                                }
                                .indicator(.activity)
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .offset(x: offset)
                                .zIndex(Double(4 - index)) // To stack properly
                        } else {
                            Image("placeholder_user")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .offset(x: offset)
                                .zIndex(Double(4 - index))
                        }
                    }
                }
                .frame(width: 40 + CGFloat(min(members.count, 4) - 1) * 20.0, height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text("small_talk_title_conversation".localized)
                        .font(.custom("Quicksand-Bold", size: 15))
                        .foregroundColor(.black)

                    Text(members.map { $0.display_name }.joined(separator: ", "))
                        .font(.custom("NunitoSans-Regular", size: 15))
                        .foregroundColor(.black)
                        .lineLimit(1)

                    if let newMessagesText = unreadCountText {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(Color("appOrange"))
                                .frame(width: 8, height: 8)

                            Text(newMessagesText)
                                .font(.custom("NunitoSans-Regular", size: 13))
                                .foregroundColor(Color("appOrange"))
                        }
                    }
                }

                Spacer()

                Image("ic_arrow_right_orange") // Ensure asset exists
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
            .padding(20)
            .background(Color("appBeige")) // Match your xib design background
            .cornerRadius(15)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
        }
    }
}
