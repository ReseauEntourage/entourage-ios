import SwiftUI

struct HomeSmallTalkCellView: View {
    var data: [CollectionDTO]
    var onTalkTapped: (UserSmallTalkRequest) -> Void
    var onCreateTapped: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    switch item {
                    case .create:
                        CellCreateSmallTalkView {
                            onCreateTapped()
                        }
                        .frame(width: UIScreen.main.bounds.width)
                    case .waiting:
                        CellWaitingSmallTalkView()
                            .frame(width: UIScreen.main.bounds.width)
                    case .talking(let request):
                        CellDiscussionSmallTalkView(request: request) {
                            onTalkTapped(request)
                        }
                        .frame(width: UIScreen.main.bounds.width)
                    }
                }
            }
        }
        .frame(height: 180) // Adjust height as necessary, matching 260 from tableView:heightForRowAt but considering margins
        .background(Color("white_orange_home"))
    }
}
