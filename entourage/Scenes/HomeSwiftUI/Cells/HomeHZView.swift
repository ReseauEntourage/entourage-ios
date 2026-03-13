import SwiftUI

struct HomeHZView: View {
    let onHZClick: (() -> Void)?

    var body: some View {
        Button(action: {
            onHZClick?()
        }) {
            ZStack(alignment: .leading) {
                Image("image_buffet")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 160)
                    .clipped()

                VStack(alignment: .leading, spacing: 8) {
                    Text("home_v2_hz_item_title".localized)
                        .font(.custom("NunitoSans-Bold", size: 18))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    Text("home_v2_hz_item_subtitle".localized)
                        .font(.custom("NunitoSans-Regular", size: 14))
                        .foregroundColor(.white)
                        .lineLimit(3)

                    Spacer()

                    Text("home_v2_hz_item_button".localized)
                        .font(.custom("NunitoSans-Bold", size: 14))
                        .foregroundColor(Color("appOrange"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(20)
                }
                .padding(20)
            }
            .frame(height: 160)
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
