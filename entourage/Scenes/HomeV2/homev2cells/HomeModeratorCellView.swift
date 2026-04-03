import SwiftUI
import SDWebImageSwiftUI

struct HomeModeratorCellView: View {
    var title: String
    var imageUrl: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                if let urlString = imageUrl, let url = URL(string: urlString) {
                    WebImage(url: url)
                        .resizable()
                        .placeholder {
                            Image("placeholder_user")
                                .resizable()
                        }
                        .indicator(.activity)
                        .scaledToFill()
                        .frame(width: 46, height: 46)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color("appOrangeLight"), lineWidth: 1))
                } else {
                    Image("placeholder_user")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 46, height: 46)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color("appOrangeLight"), lineWidth: 1))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "home_v2_moderator_title_format".localized, title))
                        .font(.custom("Quicksand-Bold", size: 15))
                        .foregroundColor(Color("black_app"))
                        .multilineTextAlignment(.leading)

                    Text("home_v2_moderator_subtitle".localized)
                        .font(.custom("NunitoSans-Regular", size: 13))
                        .foregroundColor(Color("black_app"))
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image("ic_arrow_right_orange") // Assumes you have this image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color("appBeige"), lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 5)
            .background(Color("white_orange_home"))
        }
    }
}
