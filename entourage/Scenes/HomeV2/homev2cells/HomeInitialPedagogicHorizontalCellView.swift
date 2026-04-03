import SwiftUI
import SDWebImageSwiftUI

struct HomeInitialPedagoCellView: View {
    var pedago: PedagogicResource
    var action: () -> Void

    var tagTitle: String {
        switch pedago.tag {
        case .All: return "home_v2_pedago_item_tag_all".localized
        case .Understand: return "home_v2_pedago_item_tag_understand".localized
        case .Act: return "home_v2_pedago_item_tag_act".localized
        case .Inspire: return "home_v2_pedago_item_tag_inspire".localized
        case .None: return "Autre"
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                if let imageUrl = pedago.imageUrl, let url = URL(string: imageUrl) {
                    WebImage(url: url)
                        .resizable()
                        .placeholder {
                            Image("placeholder_action")
                                .resizable()
                        }
                        .indicator(.activity)
                        .scaledToFill()
                        .frame(width: 100, height: 115) // Adjust based on xib
                        .clipped()
                } else {
                    Image("placeholder_action")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 115)
                        .clipped()
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(tagTitle)
                        .font(.custom("NunitoSans-Bold", size: 12))
                        .foregroundColor(Color("appOrangeLight")) // Same logic as HomeCellPedago? Assuming yes

                    Text(pedago.title ?? "Autre")
                        .font(.custom("Quicksand-Bold", size: 15))
                        .foregroundColor(.black)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    if let duration = pedago.duration, duration > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "clock") // Add icon if needed or just text
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.black)

                            Text(String(format: "home_v2_pedag_item_lenght_title".localized, duration))
                                .font(.system(size: 12))
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: 300, height: 115)
            .background(Color.white)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color("appBeige"), lineWidth: 1)
            )
        }
    }
}

struct HomeInitialPedagogicHorizontalCellView: View {
    var pedagos: [PedagogicResource]
    var action: (PedagogicResource) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(pedagos, id: \.id) { pedago in
                    HomeInitialPedagoCellView(pedago: pedago) {
                        action(pedago)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color("white_orange_home"))
    }
}
