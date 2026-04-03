import SwiftUI

struct HomeHZCellView: View {
    var action: () -> Void

    var body: some View {
        VStack(spacing: 15) {
            Image("img_hz_home") // Assuming the image is named "img_hz_home" based on the xib (you can adjust if needed)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .cornerRadius(15)

            Text("home_v2_hz_item_title".localized)
                .font(.system(size: 15, weight: .bold)) // Adjust font
                .foregroundColor(Color("black"))
                .multilineTextAlignment(.center)

            Text("home_v2_hz_item_subtitle".localized)
                .font(.system(size: 13)) // Adjust font
                .foregroundColor(Color("grey"))
                .multilineTextAlignment(.center)

            Button(action: action) {
                Text("home_v2_hz_item_button".localized)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("appOrange"))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("appOrange"), lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color("white_orange_home"))
    }
}
