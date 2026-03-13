import SwiftUI

struct HomeGroupCarouselView: View {
    let groups: [Neighborhood]
    let onGroupClick: ((Neighborhood) -> Void)?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(groups, id: \.uid) { group in
                    Button(action: {
                        onGroupClick?(group)
                    }) {
                        HomeGroupCardView(group: group)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 200)
    }
}

struct HomeGroupCardView: View {
    let group: Neighborhood

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: group.image_url ?? "")) { phase in
                    if let image = phase.image {
                        image.resizable()
                    } else if phase.error != nil {
                        Image("placeholder_photo_group").resizable()
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width * 0.85 - 32, height: 100)
                .clipped()

                if let unreadCount = group.unreadPostCount, unreadCount > 0 {
                    let displayCount = unreadCount > 9 ? "+9" : "\(unreadCount)"
                    Text(displayCount)
                        .font(.custom("NunitoSans-Bold", size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .clipShape(Capsule())
                        .padding(8)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(group.name ?? "")
                    .font(.custom("NunitoSans-Bold", size: 16))
                    .foregroundColor(Color("appBlack"))
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image("ic_group_members")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color("appOrange"))
                        .frame(width: 14, height: 14)

                    Text("\(group.membersCount) \("members".localized)")
                        .font(.custom("NunitoSans-Regular", size: 13))
                        .foregroundColor(Color("appGrey"))
                        .lineLimit(1)
                }
            }
            .padding(12)

            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width * 0.85 - 32, height: 180)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
}
