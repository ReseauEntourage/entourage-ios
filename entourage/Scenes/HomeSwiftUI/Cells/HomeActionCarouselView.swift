import SwiftUI

struct HomeActionCarouselView: View {
    let actions: [Action]
    let onActionClick: ((Action) -> Void)?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(actions, id: \.id) { action in
                    Button(action: {
                        onActionClick?(action)
                    }) {
                        HomeActionCardView(action: action)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 220) // Approximate height matching old UICollectionView
    }
}

struct HomeActionCardView: View {
    let action: Action

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                // Author Avatar
                AsyncImage(url: URL(string: action.author?.avatarURL ?? "")) { phase in
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
                    Text(action.author?.displayName ?? "")
                        .font(.custom("NunitoSans-Bold", size: 14))
                        .foregroundColor(.black)
                        .lineLimit(1)

                    if let dist = action.distance {
                        Text(dist.displayDistance())
                            .font(.custom("NunitoSans-Regular", size: 12))
                            .foregroundColor(Color("appGrey"))
                    } else {
                        Text("\(String(format: "AtKm".localized, "xx")) - \(action.metadata?.displayAddress ?? "")")
                            .font(.custom("NunitoSans-Regular", size: 12))
                            .foregroundColor(Color("appGrey"))
                    }
                }
                .padding(.leading, 8)

                Spacer()
            }

            Text(action.title ?? "")
                .font(.custom("NunitoSans-Bold", size: 16))
                .foregroundColor(.black)
                .lineLimit(2)

            Text(action.description ?? "")
                .font(.custom("NunitoSans-Regular", size: 14))
                .foregroundColor(Color("appGrey"))
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            Spacer()

            if let sectionName = action.sectionName {
                HStack(spacing: 4) {
                    Image(getActionTagIcon(sectionName: sectionName))
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color("appOrangeLight"))
                        .frame(width: 14, height: 14)

                    Text(getActionTagLocalizedName(sectionName: sectionName))
                        .font(.custom("NunitoSans-Regular", size: 12))
                        .foregroundColor(Color("appOrangeLight"))
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .frame(width: UIScreen.main.bounds.width * 0.85 - 32, height: 220) // Adjusted height slightly for the tag
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("appBeige"), lineWidth: 1)
        )
    }

    private func getActionTagIcon(sectionName: String) -> String {
        switch sectionName {
        case "social": return "ic_action_social"
        case "clothes": return "ic_action_clothes"
        case "equipment": return "ic_action_equipment"
        case "hygiene": return "ic_action_hygiene"
        case "services": return "ic_action_services"
        default: return "ic_action_services"
        }
    }

    private func getActionTagLocalizedName(sectionName: String) -> String {
        switch sectionName {
        case "social": return "home_v2_action_type_social".localized
        case "clothes": return "home_v2_action_type_clothes".localized
        case "equipment": return "home_v2_action_type_equipment".localized
        case "hygiene": return "home_v2_action_type_hygiène".localized
        case "services": return "home_v2_action_type_services".localized
        default: return "home_v2_action_type_other".localized
        }
    }
}
