import SwiftUI

struct HomeMapButtonView: View {
    var body: some View {
        Button(action: {
            NotificationCenter.default.post(name: NSNotification.Name(kNotificationMapOpen), object: nil)
        }) {
            HStack(spacing: 8) {
                Image("ic_map_orange")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color("appOrange"))
                    .frame(width: 24, height: 24)

                Text("home_v2_btn_map".localized)
                    .font(.custom("NunitoSans-Bold", size: 15))
                    .foregroundColor(Color("appOrange"))

                Spacer()

                Image("ic_arrow_right")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color("appOrange"))
                    .frame(width: 12, height: 12)
            }
            .padding()
            .background(Color("appBeige"))
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
