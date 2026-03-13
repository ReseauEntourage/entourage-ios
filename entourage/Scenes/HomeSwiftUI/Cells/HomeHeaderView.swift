import SwiftUI

struct HomeHeaderView: View {
    var notificationCount: Int
    var onAvatarClick: (() -> Void)?
    var onNotifClick: (() -> Void)?

    var body: some View {
        HStack {
            Button(action: { onAvatarClick?() }) {
                Image("placeholder_user")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
            }
            .padding(.leading, 16)

            Spacer()

            Button(action: { onNotifClick?() }) {
                ZStack(alignment: .topTrailing) {
                    Image("ic_notif_home")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                    if notificationCount > 0 {
                        Circle()
                            .fill(Color("appOrange"))
                            .frame(width: 12, height: 12)
                            .offset(x: -2, y: 2)
                    }
                }
            }
            .padding(.trailing, 16)
        }
        .padding(.top, 44) // approximate safe area top + 16
        .padding(.bottom, 16)
    }
}
