import SwiftUI

struct HomeSeeAllView: View {
    let seeAllType: SeeAllCellType
    let onSeeAllClick: ((SeeAllCellType) -> Void)?

    var body: some View {
        Button(action: {
            onSeeAllClick?(seeAllType)
        }) {
            HStack {
                Spacer()
                Text("see_all".localized)
                    .font(.custom("NunitoSans-Bold", size: 13))
                    .foregroundColor(Color("appOrange"))
                Image("ic_arrow_right")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color("appOrange"))
                    .frame(width: 12, height: 12)
            }
            .padding(.trailing, 20)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
    }
}
