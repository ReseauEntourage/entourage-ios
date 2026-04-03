import SwiftUI
import SDWebImageSwiftUI

struct HomeCellPedagoView: View {
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

    var tagTextColor: Color {
        switch pedago.tag {
        case .All: return Color("appOrangeLight")
        case .Understand: return Color("tagUnderstand")
        case .Act: return Color("tagAct")
        case .Inspire: return Color("tagInspire")
        case .None: return Color("appOrangeLight")
        }
    }

    var tagBackgroundColor: Color {
        switch pedago.tag {
        case .All: return Color("appBeigeLighter")
        case .Understand: return Color("tagUnderstandBackground")
        case .Act: return Color("tagActBackground")
        case .Inspire: return Color("tagInspireBackground")
        case .None: return Color("appBeigeLighter")
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                if let imageUrl = pedago.imageUrl, let url = URL(string: imageUrl) {
                    WebImage(url: url)
                        .resizable()
                        .placeholder {
                            Image("placeholder_action")
                                .resizable()
                        }
                        .indicator(.activity)
                        .scaledToFill()
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                        .clipped()
                } else {
                    Image("placeholder_action")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                        .clipped()
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(pedago.title ?? "Autre")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 10) {
                        Text(tagTitle)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(tagTextColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(tagBackgroundColor)
                            .cornerRadius(5)

                        if let duration = pedago.duration, duration > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
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
                }
                .padding(15)
            }
            .background(Color.white)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color("appBeige"), lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color("white_orange_home"))
        }
    }
}
