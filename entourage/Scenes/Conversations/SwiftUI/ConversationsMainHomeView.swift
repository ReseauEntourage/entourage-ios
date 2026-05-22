import SwiftUI

struct ConversationsMainHomeView: View {
    @StateObject var viewModel = ConversationsViewModel()

    var onShowConversation: ((ConversationMainDTO) -> Void)?
    var onShowProfile: ((Int) -> Void)?
    var onShowWebUrl: ((URL) -> Void)?
    var onRequestNotifications: (() -> Void)?

    private let filters = [
        "event_conv_filter_all".localized,
        "event_conv_filter_discussions".localized,
        "event_conv_filter_events".localized,
        "event_conv_filter_smalltalks".localized
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header Image
            Image("header_orange_light")
                .resizable()
                .scaledToFill()
                .frame(height: 109)
                .clipped()
                .overlay(
                    Text("Messages_title".localized)
                        .font(.custom("Quicksand-Bold", size: 23))
                        .foregroundColor(.black)
                        .padding(.leading, 20)
                        .padding(.bottom, 16),
                    alignment: .bottomLeading
                )
                .background(Color.white)

            // Selector View
            ZStack(alignment: .top) {
                Color.white

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.dataSource, id: \.self) { dto in
                            switch dto {
                            case .filter:
                                ConversationFilterView(
                                    filters: filters,
                                    selectedFilter: $viewModel.selectedFilter,
                                    onFilterSelected: { filter in
                                        viewModel.onFilterClick(filter: filter)
                                    }
                                )
                                .padding(.bottom, 10)

                            case .notificationRequest:
                                ConversationNotifAskView {
                                    onRequestNotifications?()
                                }
                                .padding(.bottom, 10)

                            case .conversation(let conversation):
                                ConversationListMainCellSwiftUI(
                                    conversation: conversation,
                                    currentUserId: UserDefaults.currentUser?.sid,
                                    isSmallTalk: false
                                )
                                .onAppear {
                                    viewModel.loadMoreIfNeeded(currentItem: dto)
                                }
                                .onTapGesture {
                                    onShowConversation?(dto)
                                }
                                Divider().padding(.horizontal, 16)

                            case .smalltalk(let smallTalk):
                                ConversationListMainCellSwiftUI(
                                    conversation: Conversation(from: smallTalk),
                                    currentUserId: UserDefaults.currentUser?.sid,
                                    isSmallTalk: true
                                )
                                .onAppear {
                                    viewModel.loadMoreIfNeeded(currentItem: dto)
                                }
                                .onTapGesture {
                                    onShowConversation?(dto)
                                }
                                Divider().padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
                .refreshable {
                    viewModel.loadConversations(reset: true)
                }
                .background(Color.white)
                .cornerRadius(ApplicationTheme.bigCornerRadius, corners: [.topLeft, .topRight]) // we'll use a custom corner shape or standard cornerRadius if the extension is not accessible in SwiftUI
            }
            .offset(y: -20)
            .padding(.bottom, -20)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.top)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
