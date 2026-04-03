import SwiftUI

struct HomeSeeAllCellView: View {
    var type: seeAllCellType
    var isContrib: Bool
    var action: () -> Void

    var title: String {
        switch type {
        case .seeAllDemand:
            return isContrib ? "home_v2_btn_more_action_contrib".localized : "home_v2_btn_more_action".localized
        case .seeAllEvent:
            return "home_v2_btn_more_event".localized
        case .seeAllGroup:
            return "home_v2_btn_more_group".localized
        case .seeAllPedago:
            return "home_v2_btn_more_pedago".localized
        }
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(title)
                    .font(.system(size: 15, weight: .bold)) // Adjust font to match your app's style
                    .foregroundColor(Color("appOrange")) // Adjust color to match app's primary color
                    .underline()
                Image(systemName: "arrow.right")
                    .foregroundColor(Color("appOrange"))
                Spacer()
            }
            .padding(.vertical, 15)
            .background(Color("white_orange_home"))
        }
    }
}
