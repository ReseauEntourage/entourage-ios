import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    // Callbacks to interact with UIKit navigation
    var onNotifClick: (() -> Void)?
    var onAvatarClick: (() -> Void)?
    var onActionClick: ((Action) -> Void)?
    var onEventClick: ((Event) -> Void)?
    var onGroupClick: ((Neighborhood) -> Void)?
    var onPedagoClick: ((PedagogicResource) -> Void)?
    var onSeeAllClick: ((SeeAllCellType) -> Void)?
    var onSmallTalkClick: (() -> Void)?
    var onSmallTalkConversationClick: ((UserSmallTalkRequest) -> Void)?
    var onSolidarityToolClick: ((String) -> Void)?
    var onModeratorClick: (() -> Void)?
    var onIAmLostClick: ((HomeNeedHelpType) -> Void)?
    var onHZClick: (() -> Void)?

    var body: some View {
        ZStack(alignment: .top) {
            // Background Header Image (Matches `image_top_home`)
            GeometryReader { proxy in
                Image("image_top_home")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: 200)
                    .clipped()
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header (Avatar, Greeting, Notif Button)
                HomeHeaderView(
                    notificationCount: viewModel.notificationCount,
                    onAvatarClick: onAvatarClick,
                    onNotifClick: onNotifClick
                )

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.tableDTO) { dto in
                            switch dto.type {
                            case .cellTitle(let title, let subtitle):
                                HomeTitleView(title: title, subtitle: subtitle)
                            case .cellAction(let actions):
                                HomeActionCarouselView(actions: actions, onActionClick: onActionClick)
                            case .cellSeeAll(let seeAllType):
                                HomeSeeAllView(seeAllType: seeAllType, onSeeAllClick: onSeeAllClick)
                            case .cellEvent(let events):
                                HomeEventCarouselView(events: events, onEventClick: onEventClick)
                            case .cellGroup(let groups):
                                HomeGroupCarouselView(groups: groups, onGroupClick: onGroupClick)
                            case .cellPedago(let pedago):
                                HomePedagoCardView(pedago: pedago, onPedagoClick: onPedagoClick)
                            case .cellMap:
                                HomeMapButtonView()
                            case .cellIAmLost(let helpType):
                                HomeIAmLostView(helpType: helpType, onIAmLostClick: onIAmLostClick)
                            case .moderator(let name, let imageUrl):
                                HomeModeratorView(name: name, imageUrl: imageUrl, onModeratorClick: onModeratorClick)
                            case .cellHZ:
                                HomeHZView(onHZClick: onHZClick)
                            case .cellInitialPedago(let pedagos):
                                HomeInitialPedagoCarouselView(pedagos: pedagos, onPedagoClick: onPedagoClick)
                            case .cellSmallTalk(let userRequests):
                                HomeSmallTalkView(userRequests: userRequests, onSmallTalkClick: onSmallTalkClick, onSmallTalkConversationClick: onSmallTalkConversationClick)
                            case .cellSolidarityTools:
                                HomeSolidarityToolsView(onToolClick: onSolidarityToolClick)
                            }
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
                .refreshable {
                    viewModel.fetchAllData()
                }
            }
        }
        .onAppear {
            viewModel.fetchAllData()
        }
    }
}
