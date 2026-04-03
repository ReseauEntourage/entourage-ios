import SwiftUI

struct HomeGroupHorizontalCollectionCellView: View {
    var groups: [Neighborhood]
    var action: (Neighborhood) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(groups, id: \.uid) { group in
                    HomeGroupCellView(group: group) {
                        action(group)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(Color("white_orange_home"))
    }
}
