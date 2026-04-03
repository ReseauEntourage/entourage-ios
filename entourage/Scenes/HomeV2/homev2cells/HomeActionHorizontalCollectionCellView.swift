import SwiftUI
import SDWebImageSwiftUI

struct HomeCellActionCollectionViewCellView: View {
    var action: Action
    var onTap: () -> Void

    var imageUrl: URL? {
        if let urlStr = action.author?.avatarURL, !urlStr.isEmpty {
            return URL(string: urlStr)
        }
        return nil
    }

    var distanceText: String {
        if let distance = action.distance {
            var distString = Utils.displayDistance(distance: distance)
            if distString.lowercased().hasPrefix("à ") {
                distString = String(distString.dropFirst(2))
            }
            return distString
        }
        return "-"
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                // Header (User info + Tag)
                HStack(alignment: .top) {
                    if let url = imageUrl {
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
                            .overlay(Circle().stroke(Color("appOrange"), lineWidth: 1))
                    } else {
                        Image("placeholder_user")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color("appOrange"), lineWidth: 1))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(action.author?.displayName ?? "-")
                            .font(.custom("Quicksand-Bold", size: 15))
                            .foregroundColor(.black)

                        Text(action.sectionName != nil ? TagsUtils.showTagTranslated(action.sectionName!) : "-")
                            .font(.custom("NunitoSans-Regular", size: 11))
                            .foregroundColor(Color("appOrange"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color("appBeige"))
                            .clipShape(Capsule())
                    }

                    Spacer()
                }

                // Content
                Text(action.title)
                    .font(.custom("Quicksand-Bold", size: 15))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if let desc = action.description, !desc.isEmpty {
                    let first = String(desc.prefix(1)).uppercased()
                    let other = String(desc.dropFirst())
                    Text(first + other)
                        .font(.custom("NunitoSans-Regular", size: 13))
                        .foregroundColor(Color("grey_light"))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("") // To maintain spacing if needed, or remove
                        .font(.custom("NunitoSans-Regular", size: 13))
                        .lineLimit(3)
                }

                Spacer()

                // Footer (Distance)
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse") // Fallback icon, use app's pin icon if available
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundColor(Color("appOrange"))

                    Text(distanceText)
                        .font(.custom("NunitoSans-Regular", size: 11))
                        .foregroundColor(Color("appOrange"))
                }
            }
            .padding(15)
            .frame(width: (UIScreen.main.bounds.width - 32) * 0.85, height: 215)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("appBeige"), lineWidth: 1)
            )
        }
    }
}

struct HomeActionHorizontalCollectionCellView: View {
    var actions: [Action]
    var actionTapped: (Action) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(actions, id: \.id) { action in
                    HomeCellActionCollectionViewCellView(action: action) {
                        actionTapped(action)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color("white_orange_home"))
    }
}
