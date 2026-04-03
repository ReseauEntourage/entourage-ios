import SwiftUI

struct HomeSolidarityToolsCellView: View {
    var onMapTapped: () -> Void
    var onPedagoTapped: () -> Void
    var onEthicsTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("home_v2_solidarity_tools_title".localized)
                .font(.custom("Quicksand-Bold", size: 15))
                .foregroundColor(.black)
                .padding(.horizontal, 20)

            HStack(spacing: 10) {
                ToolCardView(
                    title: "home_v2_tool_card_map".localized,
                    iconName: "ic_button_map",
                    systemIcon: "map.fill",
                    action: onMapTapped
                )

                ToolCardView(
                    title: "home_v2_tool_card_pedago".localized,
                    iconName: "ic_button_pedago",
                    systemIcon: "book.fill",
                    action: onPedagoTapped
                )

                ToolCardView(
                    title: "home_v2_tool_card_ethics".localized,
                    iconName: "ic_button_charte",
                    systemIcon: "hand.raised.fill",
                    action: onEthicsTapped
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 10)
        .background(Color("white_orange_home"))
    }
}

struct ToolCardView: View {
    var title: String
    var iconName: String
    var systemIcon: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color("appBeige"))
                        .frame(width: 50, height: 50)

                    if let img = UIImage(named: iconName) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    } else {
                        Image(systemName: systemIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color("appOrange"))
                    }
                }

                Text(title)
                    .font(.custom("Nunito-Bold", size: 12))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 35, alignment: .top)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color("appBeige"), lineWidth: 1)
            )
        }
    }
}
