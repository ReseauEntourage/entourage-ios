import SwiftUI

struct CellWaitingSmallTalkView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image("illu_small_talk_waiting") // Update image name based on your assets
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)

            VStack(alignment: .leading, spacing: 10) {
                Text("small_talk_title_waiting".localized)
                    .font(.custom("Quicksand-Bold", size: 15))
                    .foregroundColor(.black)

                Text("small_talk_subtitle_waiting".localized)
                    .font(.custom("NunitoSans-Regular", size: 15))
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(Color("appBeige")) // Updated based on xib appearance
        .cornerRadius(15)
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
    }
}
