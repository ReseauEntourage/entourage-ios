import SwiftUI

enum HomeNeedHelpType {
    case createEvent
    case createGroup
}

struct HomeIAmLostView: View {
    let helpType: HomeNeedHelpType
    let onIAmLostClick: ((HomeNeedHelpType) -> Void)?

    var body: some View {
        Button(action: {
            onIAmLostClick?(helpType)
        }) {
            HStack(spacing: 8) {
                Image(helpType == .createEvent ? "ic_calendar_home_v2" : "ic_people_home_v2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(helpType == .createEvent ? "home_v2_help_title_two".localized : "home_v2_help_title_one".localized)
                        .font(.custom("NunitoSans-Bold", size: 15))
                        .foregroundColor(Color("appBlack"))
                }

                Spacer()

                Image("ic_arrow_right")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color("appOrange"))
                    .frame(width: 12, height: 12)
            }
            .padding(16)
            .background(Color("appBeige"))
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
