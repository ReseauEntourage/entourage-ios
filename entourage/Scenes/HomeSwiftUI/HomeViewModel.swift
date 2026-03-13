import Foundation
import SwiftUI
import Combine

enum SeeAllCellType {
    case seeAllDemand
    case seeAllEvent
    case seeAllGroup
    case seeAllPedago
}

enum HomeSwiftUIDTOType {
    case cellTitle(title: String, subtitle: String)
    case cellAction(actions: [Action])
    case cellSeeAll(seeAllType: SeeAllCellType)
    case cellEvent(events: [Event])
    case cellGroup(groups: [Neighborhood])
    case cellPedago(pedago: PedagogicResource)
    case cellMap
    case cellIAmLost(helpType: HomeNeedHelpType)
    case moderator(name: String, imageUrl: String? = nil)
    case cellHZ
    case cellInitialPedago(pedagos: [PedagogicResource])
    case cellSmallTalk(userRequests: [UserSmallTalkRequest])
    case cellSolidarityTools
}

struct HomeSwiftUIDTO: Identifiable {
    let id = UUID()
    let type: HomeSwiftUIDTOType
}

class HomeViewModel: ObservableObject {
    @Published var tableDTO = [HomeSwiftUIDTO]()
    @Published var notificationCount = 0
    @Published var allGroups = [Neighborhood]()
    @Published var allEvents = [Event]()
    @Published var allDemands = [Action]()
    @Published var allPedagos = [PedagogicResource]()
    @Published var initialPedagos = [PedagogicResource]()
    @Published var userSmallTalkRequests = [UserSmallTalkRequest]()

    @Published var pedagoCreateEvent: PedagogicResource?
    @Published var pedagoCreateGroup: PedagogicResource?
    @Published var isContributionPreference: Bool = false
    @Published var userHome: UserHome!

    @Published var isLoading = false

    var currentFilter = EventActionLocationFilters()
    var currentSectionsFilter = Sections()
    var currentLocationFilter = EventActionLocationFilters()

    private var cancellables = Set<AnyCancellable>()

    init() {
        self.userHome = UserHome()
    }

    func fetchAllData() {
        isLoading = true
        getNotif()
        getUserInfo()
        loadMetadatas()
        getPedago()
    }

    func getNotif() {
        HomeService.getNotificationsCount { count, error in
            DispatchQueue.main.async {
                self.notificationCount = count ?? 0
            }
        }
    }

    func getUserInfo() {
        guard let _userid = UserDefaults.currentUser?.uuid else { return }
        UserService.getUnreadCountForUser { unreadCount, error in
            if let unreadCount = unreadCount {
                DispatchQueue.main.async {
                    UserDefaults.badgeCount = unreadCount.0
                    UserDefaults.groupBadgeCount = unreadCount.1
                    NotificationCenter.default.post(name: NSNotification.Name(kNotificationMessagesUpdateCount), object: nil)
                }
            }
        }
    }

    func getPedago() {
        HomeService.getResources { resources, error in
            DispatchQueue.main.async {
                if let resources = resources {
                    self.allPedagos.removeAll()
                    var pedagoReads = [PedagogicResource]()
                    for resource in resources {
                        if resource.isRead == false {
                            pedagoReads.append(resource)
                        }
                    }
                    for pedagoRead in pedagoReads {
                        self.allPedagos.append(pedagoRead)
                        if self.allPedagos.count >= 3 {
                            break
                        }
                    }

                    #if DEBUG
                    for pedago in resources {
                        if pedago.id == 32 {
                            self.pedagoCreateEvent = pedago
                        } else if pedago.id == 33 {
                            self.pedagoCreateGroup = pedago
                        }
                    }
                    #else
                    for pedago in resources {
                        if pedago.id == 15 {
                            self.pedagoCreateEvent = pedago
                        } else if pedago.id == 37 {
                            self.pedagoCreateGroup = pedago
                        }
                    }
                    #endif
                }
                self.getHomeDetail()
            }
        }
    }

    func getHomeDetail() {
        HomeService.getUserHome { [weak self] userHome, error in
            DispatchQueue.main.async {
                if let userHome = userHome {
                    self?.userHome = userHome
                    AppSignableManager.shared.updateFromHome(userHome: userHome)
                    if userHome.preference == "contribution" {
                        self?.isContributionPreference = true
                    } else {
                        self?.isContributionPreference = false
                    }
                    let config = EnhancedOnboardingConfiguration.shared
                    config.preference = userHome.preference ?? ""

                    AppManager.shared.isContributionPreference = self?.isContributionPreference ?? false

                    if let unclosedAction = userHome.unclosedAction, let actionType = unclosedAction.actionType, let title = unclosedAction.title {
                        self?.showPopUpAction(actionType: actionType, title: title, actionId: unclosedAction.id)
                    }
                }
                self?.getDemandes()
            }
        }
    }

    func showPopUpAction(actionType: String, title: String, actionId: Int) {
        NotificationCenter.default.post(name: NSNotification.Name("ShowUnclosedActionPopup"), object: nil, userInfo: ["actionType": actionType, "title": title, "actionId": actionId])
    }

    func getDemandes() {
        let isContrib = isContributionPreference
        ActionsService.getAllActions(isContrib: isContrib, currentPage: 1, per: 3, filtersLocation: currentLocationFilter.getfiltersForWS(), filtersSections: currentSectionsFilter.getallSectionforWS()) { [weak self] actions, error in
            DispatchQueue.main.async {
                if let actions = actions {
                    self?.allDemands.removeAll()
                    self?.allDemands.append(contentsOf: actions)
                }
                self?.getInitialPedagos()
            }
        }
    }

    func getInitialPedagos() {
        HomeService.getInitialResources { resources, error in
            DispatchQueue.main.async {
                if let resources = resources {
                    self.initialPedagos.removeAll()
                    var pedagoReads = [PedagogicResource]()
                    for resource in resources {
                        if resource.isRead == false {
                            pedagoReads.append(resource)
                        }
                    }
                    for pedagoRead in pedagoReads {
                        self.initialPedagos.append(pedagoRead)
                    }
                }
                self.getUserSmallTalkRequests()
            }
        }
    }

    func getUserSmallTalkRequests() {
        SmallTalkService.listUserSmallTalkRequests { requests, error in
            DispatchQueue.main.async {
                if let requests = requests {
                    self.userSmallTalkRequests = requests
                } else {
                    self.userSmallTalkRequests = []
                }
                self.getMyGroups()
            }
        }
    }

    func getMyGroups() {
        guard let token = UserDefaults.currentUser?.uuid else { return }
        NeighborhoodService.getNeighborhoodsForUserId(token, currentPage: 1, per: 10, completion: { groups, error in
            DispatchQueue.main.async {
                if let groups = groups {
                    self.allGroups.removeAll()
                    self.allGroups.append(contentsOf: groups)
                }
                self.getEvents()
            }
        })
    }

    func getEvents() {
        EventService.getAllEventsDiscover(currentPage: 1, per: 10, filters: currentFilter.getfiltersForWS()) { events, error in
            DispatchQueue.main.async {
                if let events = events {
                    self.allEvents.removeAll()
                    self.allEvents.append(contentsOf: events)
                }
                self.configureDTO()
                self.isLoading = false
            }
        }
    }

    func loadMetadatas() {
        MetadatasService.getMetadatas { error in
            Logger.print("***** return get metadats ? \(error)")
        }
    }

    func configureDTO() {
        var newTableDTO = [HomeSwiftUIDTO]()

        var showInitialPedago = false
        if let user = UserDefaults.currentUser, let involvements = user.involvements, involvements.contains("resources") {
            showInitialPedago = true
        }

        if showInitialPedago && initialPedagos.count > 0 {
            newTableDTO.append(HomeSwiftUIDTO(type: .cellTitle(title: "home_v2_title_initial_pedago".localized, subtitle: "home_v2_subtitle_initial_pedago".localized)))
            newTableDTO.append(HomeSwiftUIDTO(type: .cellInitialPedago(pedagos: self.initialPedagos)))
        }

        if (allDemands.count > 0) {
            if isContributionPreference {
                newTableDTO.append(HomeSwiftUIDTO(type: .cellTitle(title: "home_v2_title_action_contrib".localized, subtitle: "home_v2_subtitle_action_contrib".localized)))
                newTableDTO.append(HomeSwiftUIDTO(type: .cellAction(actions: allDemands)))
                newTableDTO.append(HomeSwiftUIDTO(type: .cellSeeAll(seeAllType: .seeAllDemand)))
            } else {
                newTableDTO.append(HomeSwiftUIDTO(type: .cellTitle(title: "home_v2_title_action".localized, subtitle: "home_v2_subtitle_action".localized)))
                newTableDTO.append(HomeSwiftUIDTO(type: .cellAction(actions: allDemands)))
                newTableDTO.append(HomeSwiftUIDTO(type: .cellSeeAll(seeAllType: .seeAllDemand)))
            }
        }

        if allEvents.count > 0 {
            newTableDTO.append(HomeSwiftUIDTO(type: .cellTitle(title: "home_v2_title_event".localized, subtitle: "home_v2_subtitle_event".localized)))
            newTableDTO.append(HomeSwiftUIDTO(type: .cellEvent(events: allEvents)))
            newTableDTO.append(HomeSwiftUIDTO(type: .cellSeeAll(seeAllType: .seeAllEvent)))
        } else {
            newTableDTO.append(HomeSwiftUIDTO(type: .cellIAmLost(helpType: .createEvent)))
        }

        var _offlineEvents = [Event]()
        for event in allEvents {
            if event.isOnline == false {
                _offlineEvents.append(event)
            }
        }
        if _offlineEvents.count == 0 && allDemands.count == 0 && !isContributionPreference {
            newTableDTO.append(HomeSwiftUIDTO(type: .cellHZ))
        }

        if let _moderator = userHome.moderator {
            if let _name = _moderator.displayName {
                newTableDTO.append(HomeSwiftUIDTO(type: .moderator(name: _name, imageUrl: _moderator.imgUrl)))
            }
        }

        newTableDTO.append(HomeSwiftUIDTO(type: .cellSmallTalk(userRequests: self.userSmallTalkRequests)))

        newTableDTO.append(HomeSwiftUIDTO(type: .cellSolidarityTools))

        if allGroups.count > 0 {
            newTableDTO.append(HomeSwiftUIDTO(type: .cellTitle(title: "home_v2_title_group".localized, subtitle: "home_v2_subtitle_group".localized)))
            newTableDTO.append(HomeSwiftUIDTO(type: .cellGroup(groups: allGroups)))
            newTableDTO.append(HomeSwiftUIDTO(type: .cellSeeAll(seeAllType: .seeAllGroup)))
        } else {
            newTableDTO.append(HomeSwiftUIDTO(type: .cellIAmLost(helpType: .createGroup)))
        }

        if allPedagos.count > 0 {
            for pedago in allPedagos {
                newTableDTO.append(HomeSwiftUIDTO(type: .cellPedago(pedago: pedago)))
            }
        }

        self.tableDTO = newTableDTO
    }
}
