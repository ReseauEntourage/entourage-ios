import SwiftUI

struct HomeV2CellTitleView: View {
    var title: String
    var subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 20, weight: .bold)) // Adjust font to match your app's style
                .foregroundColor(Color("black")) // Adjust color

            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 15)) // Adjust font
                    .foregroundColor(Color("grey")) // Adjust color
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("white_orange_home"))
    }
}
