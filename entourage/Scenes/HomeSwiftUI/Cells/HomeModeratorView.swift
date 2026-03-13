import SwiftUI

struct HomeModeratorView: View {
    let name: String
    let imageUrl: String?
    let onModeratorClick: (() -> Void)?

    var body: some View {
        Button(action: {
            onModeratorClick?()
        }) {
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: imageUrl ?? "")) { phase in
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
                .overlay(Circle().stroke(Color("appOrange"), lineWidth: 2))

                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "home_v2_moderator_title_format".localized, name))
                        .font(.custom("Quicksand-Bold", size: 15))
                        .foregroundColor(Color("appBlack"))
                        .lineLimit(1)

                    Text("home_v2_moderator_subtitle".localized)
                        .font(.custom("NunitoSans-Regular", size: 13))
                        .foregroundColor(Color("appGrey"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image("ic_arrow_right")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color("appOrange"))
                    .frame(width: 12, height: 12)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("appBeige"), lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
