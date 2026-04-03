import SwiftUI
import SDWebImageSwiftUI

struct HomeGroupCellView: View {
    var group: Neighborhood
    var action: () -> Void

    var imageUrl: URL? {
        if let urlStr = group.image_url, !urlStr.isEmpty {
            return URL(string: urlStr)
        }
        return nil
    }

    var unreadCountText: String? {
        if let count = group.unreadPostCount, count > 0 {
            return count > 9 ? "+9" : "\(count)"
        }
        return nil
    }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 0) {
                    if let url = imageUrl {
                        WebImage(url: url)
                            .resizable()
                            .placeholder {
                                Image("placeholder_photo_group")
                                    .resizable()
                            }
                            .indicator(.activity)
                            .scaledToFill()
                            .frame(height: 100)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    } else {
                        Image("placeholder_photo_group")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 100)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    }

                    Text(group.name)
                        .font(.custom("Quicksand-Bold", size: 13))
                        .foregroundColor(Color("black_app"))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: 0)
                }
                .frame(width: 150, height: 152) // Adjusted size based on current layout
                .background(Color.white)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color("appBeige"), lineWidth: 1)
                )

                if let badgeText = unreadCountText {
                    Text(badgeText)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color("appOrange"))
                        .clipShape(Capsule())
                        .padding([.top, .trailing], 8)
                }
            }
        }
    }
}
