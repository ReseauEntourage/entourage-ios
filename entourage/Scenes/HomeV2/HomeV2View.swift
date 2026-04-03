import SwiftUI

struct HomeV2View: View {
    @ObservedObject var viewModel: HomeV2ViewModel

    // Pour gérer l'animation du header au scroll
    @State private var scrollOffset: CGFloat = 0
    private let headerMaxHeight: CGFloat = 80 // Adjust as needed
    private let headerMinHeight: CGFloat = 60

    var body: some View {
        VStack(spacing: 0) {
            // Header Custom
            headerView
                .background(Color.white)
                .zIndex(1) // Keep header on top

            // Contenu principal
            ScrollView {
                // Tracking scroll offset
                GeometryReader { proxy in
                    Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
                }
                .frame(height: 0)

                LazyVStack(spacing: 0) {

                    // Welcome Journey
                    if !viewModel.welcomeJourneyViewModel.hideEntirely {
                        HomeWelcomeJourneyView(
                            viewModel: viewModel.welcomeJourneyViewModel,
                            onStepTapped: { step in
                                viewModel.onWelcomeJourneyStepTapped?(step)
                            }
                        )
                    }

                    // Initial Pedago
                    if let user = viewModel.currentUser, let involvements = user.involvements, involvements.contains("resources"), !viewModel.initialPedagos.isEmpty {
                        HomeV2CellTitleView(title: "home_v2_title_initial_pedago".localized, subtitle: "home_v2_subtitle_initial_pedago".localized)
                        HomeInitialPedagogicHorizontalCellView(pedagos: viewModel.initialPedagos) { pedago in
                            viewModel.onShowPedagogic?(pedago)
                        }
                    }

                    // Actions (Demands/Contribs)
                    if !viewModel.allDemands.isEmpty {
                        if viewModel.isContributionPreference {
                            HomeV2CellTitleView(title: "home_v2_title_action_contrib".localized, subtitle: "home_v2_subtitle_action_contrib".localized)
                        } else {
                            HomeV2CellTitleView(title: "home_v2_title_action".localized, subtitle: "home_v2_subtitle_action".localized)
                        }

                        HomeActionHorizontalCollectionCellView(actions: viewModel.allDemands) { action in
                            viewModel.onShowAction?(action, viewModel.isContributionPreference)
                        }

                        HomeSeeAllCellView(type: .seeAllDemand, isContrib: viewModel.isContributionPreference) {
                            viewModel.onSeeAllDemands?()
                        }
                    }

                    // Events
                    if !viewModel.allEvents.isEmpty {
                        HomeV2CellTitleView(title: "home_v2_title_event".localized, subtitle: "home_v2_subtitle_event".localized)

                        HomeEventHorizontalCollectionCellView(events: viewModel.allEvents) { event in
                            viewModel.onShowEvent?(event)
                        }

                        HomeSeeAllCellView(type: .seeAllEvent, isContrib: viewModel.isContributionPreference) {
                            viewModel.onSeeAllEvents?()
                        }
                    }

                    // HZ Cell (if no offline events and no demands and not contrib)
                    let offlineEvents = viewModel.allEvents.filter { !$0.isOnline }
                    if offlineEvents.isEmpty && viewModel.allDemands.isEmpty && !viewModel.isContributionPreference {
                        HomeHZCellView {
                            viewModel.onGoBuffet?()
                        }
                    }

                    // Moderator
                    if let moderator = viewModel.userHome.moderator, let name = moderator.displayName {
                        HomeModeratorCellView(title: name, imageUrl: moderator.imgUrl) {
                            viewModel.onModeratorClick?(moderator.id ?? 0)
                        }
                    }

                    // Small Talk
                    HomeSmallTalkCellView(
                        data: smallTalkData(),
                        onTalkTapped: { request in
                            viewModel.onTalkTapped?(request)
                        },
                        onCreateTapped: {
                            viewModel.onCreateSmallTalkTapped?()
                        }
                    )

                    // Solidarity Tools
                    HomeSolidarityToolsCellView(
                        onMapTapped: { viewModel.onMapClick?() },
                        onPedagoTapped: { viewModel.onSeeAllPedagos?() },
                        onEthicsTapped: { viewModel.onSolidarityEthicsTapped?() }
                    )

                    // Pedagos
                    if !viewModel.allPedagos.isEmpty {
                        ForEach(viewModel.allPedagos, id: \.id) { pedago in
                            HomeCellPedagoView(pedago: pedago) {
                                viewModel.onShowPedagogic?(pedago)
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
                .background(Color("white_orange_home"))
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                self.scrollOffset = value
            }
        }
        .background(Color("white_orange_home").edgesIgnoringSafeArea(.all))
        .onAppear {
            viewModel.loadData()
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            // Avatar
            Button(action: {
                viewModel.onAvatarClick?()
            }) {
                if let avatarURLString = viewModel.userHome.avatarURL, let url = URL(string: avatarURLString) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable()
                        } else {
                            Image("placeholder_user").resizable()
                        }
                    }
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                } else {
                    Image("placeholder_user")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                }
            }

            Spacer()

            // Subtitle / Title fading based on scroll
            Text("home_v2_title".localized)
                .font(.custom("Quicksand-Bold", size: 18))
                .foregroundColor(.black)
                .opacity(scrollOffset < -20 ? 0 : 1) // Simple fade out
                .animation(.easeInOut, value: scrollOffset)

            Spacer()

            // Notification Bell
            Button(action: {
                viewModel.onNotifClick?()
            }) {
                ZStack {
                    Circle()
                        .fill(viewModel.notificationCount > 0 ? Color("appOrangeDark") : Color.white)
                        .frame(width: 36, height: 36)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)

                    Image(viewModel.notificationCount > 0 ? "ic_notif_on" : "ic_notif_off")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, scrollOffset < -20 ? 5 : 15) // Reduce padding on scroll
        .animation(.easeInOut, value: scrollOffset)
    }

    // Helper for Small Talk DTO mapping
    private func smallTalkData() -> [CollectionDTO] {
        var dto: [CollectionDTO] = []
        let requests = viewModel.userSmallTalkRequests
        let matchedRequests = requests.filter { $0.smalltalk != nil }
        let pendingRequests = requests.filter { $0.smalltalk == nil }

        for req in matchedRequests {
            dto.append(.talking(req))
        }

        let hasWaiting = !pendingRequests.isEmpty
        if hasWaiting {
            dto.append(.waiting)
        }

        let shouldAddCreate = matchedRequests.count < 3 && !hasWaiting
        if shouldAddCreate {
            dto.append(.create)
        }
        return dto
    }
}

// Preference key for scroll offset tracking
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
