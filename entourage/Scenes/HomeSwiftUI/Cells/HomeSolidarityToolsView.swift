import SwiftUI

struct HomeSolidarityToolsView: View {
    let onToolClick: ((String) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("home_v2_solidarity_tools_title".localized)
                .font(.custom("NunitoSans-Bold", size: 18))
                .foregroundColor(Color("appBlack"))
                .padding(.horizontal, 16)

            HStack(spacing: 12) {
                ToolButton(imageName: "ic_button_map", title: "home_v2_tool_card_map".localized, action: { onToolClick?("map") })
                ToolButton(imageName: "ic_button_pedago", title: "home_v2_tool_card_pedago".localized, action: { onToolClick?("pedago") })
                ToolButton(imageName: "ic_button_charte", title: "home_v2_tool_card_charte".localized, action: { onToolClick?("charte") })
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
    }
}

struct ToolButton: View {
    let imageName: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    Circle()
                        .fill(Color("appBeige"))
                        .frame(width: 60, height: 60)

                    Image(imageName)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color("appOrange"))
                        .frame(width: 30, height: 30)
                }

                Text(title)
                    .font(.custom("NunitoSans-Regular", size: 12))
                    .foregroundColor(Color("appBlack"))
            }
        }
        .frame(maxWidth: .infinity)
    }
}
