import SwiftUI

struct HomeEventHorizontalCollectionCellView: View {
    var events: [Event]
    var action: (Event) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(events, id: \.uid) { event in
                    HomeCellEventView(event: event) {
                        action(event)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(Color("white_orange_home"))
    }
}
