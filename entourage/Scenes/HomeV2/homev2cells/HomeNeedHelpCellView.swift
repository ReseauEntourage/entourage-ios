import SwiftUI

struct HomeNeedHelpCellView: View {
    var type: HomeNeedHelpType
    var action: () -> Void

    var title: String {
        switch type {
        case .createEvent:
            return "home_v2_help_title_two".localized
        case .createGroup:
            return "home_v2_help_title_one".localized
        }
    }

    var iconName: String {
        switch type {
        case .createEvent:
            return "ic_calendar_home_v2"
        case .createGroup:
            return "ic_people_home_v2"
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color("appOrange"))

                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("black"))

                Spacer()

                Image("ic_arrow_right_orange") // Assumes this image exists in your assets
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
