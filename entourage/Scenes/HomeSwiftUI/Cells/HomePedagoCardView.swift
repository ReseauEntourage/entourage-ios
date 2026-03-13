import SwiftUI

struct HomePedagoCardView: View {
    let pedago: PedagogicResource
    let onPedagoClick: ((PedagogicResource) -> Void)?

    var body: some View {
        Button(action: {
            onPedagoClick?(pedago)
        }) {
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: pedago.imageUrl ?? "")) { phase in
                    if let image = phase.image {
                        image.resizable()
                    } else if phase.error != nil {
                        Image("placeholder_pedago").resizable()
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                .clipped()

                VStack(alignment: .leading, spacing: 4) {
                    Text(pedago.title ?? "")
                        .font(.custom("NunitoSans-Bold", size: 16))
                        .foregroundColor(Color("appBlack"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 10) {
                        Text(getPedagoTagText(pedago.tag))
                            .font(.custom("NunitoSans-Bold", size: 12))
                            .foregroundColor(getPedagoTagTextColor(pedago.tag))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(getPedagoTagBgColor(pedago.tag))
                            .cornerRadius(12)

                        if let duration = pedago.duration, duration > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(.black)
                                Text(String(format: "home_v2_pedag_item_lenght_title".localized, duration))
                                    .font(.custom("NunitoSans-Regular", size: 12))
                                    .foregroundColor(.black)
                            }
                        }
                    }
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
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func getPedagoTagText(_ tag: PedagogicTags) -> String {
        switch tag {
        case .All: return "home_v2_pedago_item_tag_all".localized
        case .Understand: return "home_v2_pedago_item_tag_understand".localized
        case .Act: return "home_v2_pedago_item_tag_act".localized
        case .Inspire: return "home_v2_pedago_item_tag_inspire".localized
        case .None: return "Autre"
        }
    }

    private func getPedagoTagTextColor(_ tag: PedagogicTags) -> Color {
        switch tag {
        case .All: return Color("appOrangeLight")
        case .Understand: return Color("appTagUnderstand")
        case .Act: return Color("appTagAct")
        case .Inspire: return Color("appTagInspire")
        case .None: return Color("appOrangeLight")
        }
    }

    private func getPedagoTagBgColor(_ tag: PedagogicTags) -> Color {
        switch tag {
        case .All: return Color("appBeigeLighter")
        case .Understand: return Color("appTagUnderstandBackground")
        case .Act: return Color("appTagActBackground")
        case .Inspire: return Color("appTagInspireBackground")
        case .None: return Color("appBeigeLighter")
        }
    }
}
