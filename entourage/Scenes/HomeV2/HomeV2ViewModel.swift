import Foundation
import Combine
import CoreLocation
import GooglePlaces
import SwiftUI

class HomeV2ViewModel: ObservableObject {

    @Published var notificationCount: Int = 0
    @Published var allGroups: [Neighborhood] = []
    @Published var allEvents: [Event] = []
    @Published var allDemands: [Action] = []
    @Published var allPedagos: [PedagogicResource] = []
    @Published var initialPedagos: [PedagogicResource] = []

    @Published var userHome: UserHome = UserHome()
    @Published var currentUser: User? = UserDefaults.currentUser
    @Published var userSmallTalkRequests: [UserSmallTalkRequest] = []

    @Published var isContributionPreference: Bool = false
    @Published var hasInitiallyCompletedAll: Bool? = nil

    @Published var welcomeJourneyViewModel: WelcomeJourneyViewModel = WelcomeJourneyViewModel()

    var currentFilter = EventActionLocationFilters()
    var currentLocationFilter = EventActionLocationFilters()
    var currentSectionsFilter = Sections()

    var pedagoCreateEvent: PedagogicResource?
    var pedagoCreateGroup: PedagogicResource?
    var shouldLaunchEventPopup: Int? = nil
    var shouldTestOnboarding = false

    // Navigation Callbacks
    var onAvatarClick: (() -> Void)?
    var onNotifClick: (() -> Void)?
    var onSeeAllDemands: (() -> Void)?
    var onSeeAllEvents: (() -> Void)?
    var onSeeAllGroups: (() -> Void)?
    var onSeeAllPedagos: (() -> Void)?
    var onMapClick: (() -> Void)?
    var onShowPedagogic: ((PedagogicResource) -> Void)?
    var onShowEvent: ((Event) -> Void)?
    var onShowGroup: ((Neighborhood) -> Void)?
    var onShowAction: ((Action, Bool) -> Void)?
    var onModeratorClick: ((Int) -> Void)?
    var onGoBuffet: (() -> Void)?
    var onSolidarityEthicsTapped: (() -> Void)?
    var onWelcomeJourneyStepTapped: ((WelcomeJourneyStepType) -> Void)?
    var onTalkTapped: ((UserSmallTalkRequest) -> Void)?
    var onCreateSmallTalkTapped: (() -> Void)?
    var onDataLoaded: (() -> Void)?

    func loadData() {
        currentFilter.resetToDefault()
        self.currentUser = UserDefaults.currentUser

        if let _user = UserDefaults.currentUser {
            UserService.getDetailsForUser(userId: String(_user.sid)) { [weak self] user, error in
                if error == nil {
                    UserDefaults.currentUser = user
                    self?.currentUser = user
                }
            }
        }

        loadMetadatas()
        getNotif()
        getUserInfo()
    }

    func getNotif() {
        HomeService.getNotificationsCount { [weak self] count, error in
            self?.notificationCount = count ?? 0
            self?.getMyGroups()
        }
    }

    func getMyGroups() {
        guard let token = UserDefaults.currentUser?.uuid else { return }
        NeighborhoodService.getNeighborhoodsForUserId(token, currentPage: 1, per: 10) { [weak self] groups, error in
            if let groups = groups {
                self?.allGroups = groups
            }
            self?.getEvents()
        }
    }

    func getEvents() {
        EventService.getAllEventsDiscover(currentPage: 1, per: 10, filters: currentFilter.getfiltersForWS()) { [weak self] events, error in
            if let events = events {
                self?.allEvents = events
            }
            self?.getPedago()
        }
    }

    func getPedago() {
        HomeService.getResources { [weak self] resources, error in
            guard let self = self else { return }
            if let resources = resources {
                self.allPedagos.removeAll()
                let pedagoReads = resources.filter { !$0.isRead }
                for pedagoRead in pedagoReads {
                    self.allPedagos.append(pedagoRead)
                    if self.allPedagos.count >= 3 {
                        break
                    }
                }

                #if DEBUG
                self.pedagoCreateEvent = resources.first(where: { $0.id == 32 })
                self.pedagoCreateGroup = resources.first(where: { $0.id == 33 })
                #else
                self.pedagoCreateEvent = resources.first(where: { $0.id == 15 })
                self.pedagoCreateGroup = resources.first(where: { $0.id == 37 })
                #endif
            }
            self.getHomeDetail()
        }
    }

    func getHomeDetail() {
        HomeService.getUserHome { [weak self] userHome, error in
            guard let self = self else { return }
            if let userHome = userHome {
                self.userHome = userHome
                AppSignableManager.shared.updateFromHome(userHome: userHome)
                self.isContributionPreference = (userHome.preference == "contribution")

                let config = EnhancedOnboardingConfiguration.shared
                config.preference = userHome.preference ?? ""
                AppManager.shared.isContributionPreference = self.isContributionPreference

                self.welcomeJourneyViewModel.update(with: userHome.events, hasInitiallyCompletedAll: &self.hasInitiallyCompletedAll)

                // Show unclosed action popup if needed
                if let unclosedAction = userHome.unclosedAction, let actionType = unclosedAction.actionType, let title = unclosedAction.title {
                    self.onShowUnclosedActionPopup?(actionType, title, unclosedAction.id)
                }
            }
            self.getDemandes()
        }
    }

    var onShowUnclosedActionPopup: ((String, String, Int?) -> Void)?

    func getDemandes() {
        let isContrib = isContributionPreference
        ActionsService.getAllActions(isContrib: isContrib, currentPage: 1, per: 3, filtersLocation: currentLocationFilter.getfiltersForWS(), filtersSections: currentSectionsFilter.getallSectionforWS()) { [weak self] actions, error in
            if let actions = actions {
                self?.allDemands = actions
            }
            self?.getInitialPedagos()
        }
    }

    func getInitialPedagos() {
        HomeService.getInitialResources { [weak self] resources, error in
            if let resources = resources {
                self?.initialPedagos = resources.filter { !$0.isRead }
            }
            self?.getUserSmallTalkRequests()
        }
    }

    func getUserSmallTalkRequests() {
        SmallTalkService.listUserSmallTalkRequests { [weak self] requests, error in
            if let requests = requests {
                self?.userSmallTalkRequests = requests
            } else {
                self?.userSmallTalkRequests = []
            }
            self?.onDataLoaded?()
        }
    }

    func getUserInfo() {
        UserService.getUnreadCountForUser { unreadCount, error in
            if let unreadCount = unreadCount {
                UserDefaults.badgeCount = unreadCount.0
                UserDefaults.groupBadgeCount = unreadCount.1
                NotificationCenter.default.post(name: NSNotification.Name(kNotificationMessagesUpdateCount), object: nil)
            }
        }
    }

    func loadMetadatas() {
        MetadatasService.getMetadatas { error in
            // Handle error if needed
        }
    }
}
