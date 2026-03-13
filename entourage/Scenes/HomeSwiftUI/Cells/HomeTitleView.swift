import SwiftUI

struct HomeTitleView: View {
    var title: String
    var subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.custom("NunitoSans-Bold", size: 18))
                .foregroundColor(Color("appBlack"))

            Text(subtitle)
                .font(.custom("NunitoSans-Regular", size: 13))
                .foregroundColor(Color("appGrey"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 8)
    }
}
