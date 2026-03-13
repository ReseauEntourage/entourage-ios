import UIKit
import SwiftUI
import CoreLocation
import GooglePlaces
import SafariServices

class HomeViewController: UIHostingController<HomeView>, WelcomeOneDelegate, WelcomeTwoDelegate, WelcomeThreeDelegate, Phase3fromAppDelegate, MJAlertControllerDelegate, NotificationDelegate, PopupBienCommunViewControllerDelegate, PlaceViewControllerDelegate {

    var viewModel: HomeViewModel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: HomeView(viewModel: HomeViewModel()))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(showUnclosedActionPopup(_:)), name: NSNotification.Name("ShowUnclosedActionPopup"), object: nil)

        let vm = HomeViewModel()
        self.viewModel = vm
        self.rootView = HomeView(
            viewModel: vm,
            onNotifClick: { [weak self] in self?.onNotifClick() },
            onAvatarClick: { [weak self] in self?.onAvatarClick() },
            onActionClick: { [weak self] action in self?.onActionClick(action: action) },
            onEventClick: { [weak self] event in self?.onEventClick(event: event) },
            onGroupClick: { [weak self] group in self?.onGroupClick(group: group) },
            onPedagoClick: { [weak self] pedago in self?.onPedagoClick(pedago: pedago) },
            onSeeAllClick: { [weak self] type in self?.onSeeAllClick(type: type) },
            onSmallTalkClick: { [weak self] in self?.onSmallTalkClick() },
            onSmallTalkConversationClick: { [weak self] request in self?.onSmallTalkConversationClick(request: request) },
            onSolidarityToolClick: { [weak self] tool in self?.onSolidarityToolClick(tool: tool) },
            onModeratorClick: { [weak self] in self?.onModeratorClick() },
            onIAmLostClick: { [weak self] type in self?.onIAmLostClick(type: type) },
            onHZClick: { [weak self] in self?.onHZClick() }
        )
    }


    var hasRunEntryGating = false
    var shouldLaunchEventPopup: Int? = nil

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchAllData()
        runHomeEntryGatingIfNeeded()

        if let eventId = shouldLaunchEventPopup {
            getEventAndLaunchPopup(eventId: String(eventId))
            shouldLaunchEventPopup = nil
        }

        handleEnhancedOnboardingReturn()
    }

    private func handleEnhancedOnboardingReturn() {
        let config = EnhancedOnboardingConfiguration.shared
        if config.shouldSendOnboardingFromNormalWay {
            SVProgressHUD.dismiss()
            self.presentEnhancedOnboardingIntro()
            return
        }

        if config.isFromOnboardingFromNormalWay {
            config.isFromOnboardingFromNormalWay = false
            SVProgressHUD.dismiss()
            if let _category = OnboardingEndChoicesManager.shared.categoryForButton {
                if _category.contains("both_action") || _category.contains("no_event") {
                    if let _vc = AppState.getTopViewController() {
                        if let _tabbar = _vc.tabBarController as? MainTabbarViewController {
                            let sb = UIStoryboard.init(name: StoryboardName.actionCreate, bundle: nil)
                            if let vc = sb.instantiateViewController(withIdentifier: "actionCreateVCMain") as? ActionCreateMainViewController {
                                OnboardingEndChoicesManager.shared.categoryForButton = ""
                                vc.modalPresentationStyle = .fullScreen
                                vc.isContrib = true
                                vc.parentController = self
                                _tabbar.present(vc, animated: true)
                            }
                        }
                    }
                } else if _category.contains("event") {
                    DeepLinkManager.showOutingListUniversalLink()
                } else if _category.contains("resources") {
                    OnboardingEndChoicesManager.shared.categoryForButton = ""
                    let urlString = "https://kahoot.it/challenge/45371e80-fe50-4be5-afec-b37e3d50ede2_1733228323615"
                    if let url = URL(string: urlString) {
                        if let _vc = AppState.getTopViewController() {
                            if let _tabbar = _vc.tabBarController as? MainTabbarViewController {
                                WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: _tabbar)
                            }
                        }
                    }
                } else if _category.contains("neighborhoods") {
                    OnboardingEndChoicesManager.shared.categoryForButton = ""
                    DeepLinkManager.showWelcomeTwo()
                }
            }
        }

        if config.isInterestsFromSetting {
            config.isInterestsFromSetting = false
            SVProgressHUD.dismiss()
            let navVC = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil).instantiateViewController(withIdentifier: "profileFull")
            navVC.modalPresentationStyle = .fullScreen
            self.tabBarController?.present(navVC, animated: false)
            return
        }

        if config.isOnboardingFromSetting {
            config.isOnboardingFromSetting = false
            SVProgressHUD.dismiss()
            let navVC = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil).instantiateViewController(withIdentifier: "profileFull")
            navVC.modalPresentationStyle = .fullScreen
            self.tabBarController?.present(navVC, animated: false)
            return
        }
    }

    // MARK: - Navigation Callbacks

    private func onNotifClick() {
        AnalyticsLoggerManager.logEvent(name: Action__Home__Notif)
        let storyboard = UIStoryboard(name: StoryboardName.main, bundle: nil)
        if let navVC = storyboard.instantiateViewController(withIdentifier: "notifsNav") as? UINavigationController {
            navVC.modalPresentationStyle = .fullScreen
            if let vc = navVC.topViewController as? NotificationsInAppViewController {
                vc.hasToShowDot = viewModel.notificationCount > 0
                // Needs appropriate delegate if used
            }
            self.tabBarController?.present(navVC, animated: true)
        }
    }

    private func onSmallTalkConversationClick(request: UserSmallTalkRequest) {
        let sb = UIStoryboard(name: StoryboardName.messages, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController,
           let smalltalkId = request.smalltalk_id {
            let smalltalkIdString = String(smalltalkId)
            vc.setupFromOtherVC(conversationId: smalltalkId, title: "Bonnes ondes", isOneToOne: true, conversation: nil)
            vc.isSmallTalkMode = true
            vc.smallTalkId = smalltalkIdString
            self.tabBarController?.present(vc, animated: true)
        }
    }

    private func onAvatarClick() {
        AnalyticsLoggerManager.logEvent(name: Action__Tab__Profil)
        let storyboard = UIStoryboard(name: StoryboardName.profileParams, bundle: nil)
        let navVC = storyboard.instantiateViewController(withIdentifier: "profileFull")
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
    }

    private func onActionClick(action: Action) {
        let isContrib = viewModel.isContributionPreference
        if isContrib {
            AnalyticsLoggerManager.logEvent(name: Action_Home_Contrib_Detail)
        } else {
            AnalyticsLoggerManager.logEvent(name: Action_Home_Demand_Detail)
        }

        let storyboard = UIStoryboard(name: StoryboardName.actions, bundle: nil)
        if let actionVC = storyboard.instantiateViewController(withIdentifier: "actionDetailFull") as? ActionDetailFullViewController {
            actionVC.actionId = action.id
            actionVC.action = action
            actionVC.isContrib = isContrib

            let navVC = UINavigationController(rootViewController: actionVC)
            navVC.modalPresentationStyle = .fullScreen
            self.tabBarController?.present(navVC, animated: true)
        }
    }

    private func onEventClick(event: Event) {
        let storyboard = UIStoryboard(name: StoryboardName.event, bundle: nil)
        if let eventVC = storyboard.instantiateViewController(withIdentifier: "eventDetailFeed") as? EventDetailFeedViewController {
            eventVC.eventId = event.uid
            eventVC.event = event
            eventVC.isAfterCreation = false

            let navVC = UINavigationController(rootViewController: eventVC)
            navVC.modalPresentationStyle = .fullScreen
            self.tabBarController?.present(navVC, animated: true)
        }
    }

    private func onGroupClick(group: Neighborhood) {
        let storyboard = UIStoryboard(name: StoryboardName.neighborhood, bundle: nil)
        if let groupVC = storyboard.instantiateViewController(withIdentifier: "neighborhoodDetail") as? NeighborhoodDetailViewController {
            groupVC.neighborhoodId = group.uid
            groupVC.neighborhood = group
            groupVC.isAfterCreation = false

            let navVC = UINavigationController(rootViewController: groupVC)
            navVC.modalPresentationStyle = .fullScreen
            self.tabBarController?.present(navVC, animated: true)
        }
    }

    private func onPedagoClick(pedago: PedagogicResource) {
        if pedago.id == 32 || pedago.id == 15 {
            AnalyticsLoggerManager.logEvent(name: Action_Home_Pedago_Events)
        } else if pedago.id == 33 || pedago.id == 37 {
            AnalyticsLoggerManager.logEvent(name: Action_Home_Pedago_Group)
        }

        // Remove from initial pedagos logic
        if let index = viewModel.initialPedagos.firstIndex(where: { $0.id == pedago.id }) {
            viewModel.initialPedagos.remove(at: index)
            viewModel.configureDTO()
        }

        let storyboard = UIStoryboard(name: StoryboardName.pedagogic, bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "pedagogicDetail") as? PedagogicDetailViewController {
            vc.resourceId = pedago.id
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            self.tabBarController?.present(navVC, animated: true)
        }
    }

    private func onSeeAllClick(type: SeeAllCellType) {
        switch type {
        case .seeAllDemand:
            if let _tabbar = self.tabBarController as? MainTabbarViewController {
                _tabbar.selectedIndex = 3 // Assuming 3 is Actions
                if viewModel.isContributionPreference {
                    _tabbar.showActionsContrib()
                } else {
                    _tabbar.showActionsDemand()
                }
            }
        case .seeAllEvent:
            if let _tabbar = self.tabBarController as? MainTabbarViewController {
                _tabbar.selectedIndex = 2 // Assuming 2 is Events
                _tabbar.showDiscoverEvents()
            }
        case .seeAllGroup:
            if let _tabbar = self.tabBarController as? MainTabbarViewController {
                _tabbar.selectedIndex = 1 // Assuming 1 is Groups
                _tabbar.showMyNeighborhoods()
            }
        case .seeAllPedago:
            let storyboard = UIStoryboard(name: StoryboardName.pedagogic, bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "listPedagoNav") {
                self.navigationController?.present(vc, animated: true)
            }
        }
    }

    private func onSmallTalkClick() {
        let storyboard = UIStoryboard(name: "SmallTalk", bundle: nil)
        if let vc = storyboard.instantiateInitialViewController() {
            vc.modalPresentationStyle = .fullScreen
            self.tabBarController?.present(vc, animated: true)
        }
    }

    private func onSolidarityToolClick(tool: String) {
        switch tool {
        case "map":
            AnalyticsLoggerManager.logEvent(name: Action__Home__Map)
            NotificationCenter.default.post(name: NSNotification.Name(kNotificationMapOpen), object: nil)
        case "pedago":
            AnalyticsLoggerManager.logEvent(name: Action_Home_Pedago_Events) // or similar based on old logic
            let storyboard = UIStoryboard(name: StoryboardName.pedagogic, bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "listPedagoNav") {
                self.navigationController?.present(vc, animated: true)
            }
        case "charte":
            // AnalyticsLoggerManager.logEvent(name: home_v2_action_charte) // Missing string, skipped
            let isProd = EnvironmentConfigurationManager.sharedInstance.runsOnProduction
            let urlString = isProd ? "https://www.entourage.social/app/resources/eMU_InNSSJbE" : "https://preprod.entourage.social/app/resources/87203debda8b"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        default:
            break
        }
    }

    private func onModeratorClick() {
        // AnalyticsLoggerManager.logEvent(name: home_v2_action_moderator) // Missing string, skipped
        guard let currentUserId = UserDefaults.currentUser?.uuid,
              let currentUserIdInt = Int(currentUserId),
              let _moderator = viewModel.userHome.moderator else { return }

        MessagingService.createOrGetConversation(userId: String(_moderator.id)) { conversation, error in
            if let conversation = conversation {
                DeepLinkManager.showConversation(conversationId: conversation.uid)
            }
        }
    }

    private func onIAmLostClick(type: HomeNeedHelpType) {
        switch type {
        case .createEvent:
            AnalyticsLoggerManager.logEvent(name: Action_Home_Pedago_Events)
            if let pedago = viewModel.pedagoCreateEvent {
                showPedagogic(pedagogic: pedago)
            }
        case .createGroup:
            AnalyticsLoggerManager.logEvent(name: Action_Home_Pedago_Group)
            if let pedago = viewModel.pedagoCreateGroup {
                showPedagogic(pedagogic: pedago)
            }
        }
    }

    private func showPedagogic(pedagogic: PedagogicResource) {
        let storyboard = UIStoryboard(name: StoryboardName.pedagogic, bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "pedagogicDetail") as? PedagogicDetailViewController {
            vc.resourceId = pedagogic.id
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            self.tabBarController?.present(navVC, animated: true)
        }
    }

    private func onHZClick() {
        let urlStr = "https://reseauentourage.notion.site/Buffet-du-lien-social-69c20e089dbd483cb093e90ae2953a54"
        if let webUrl = URL(string: urlStr) {
            WebLinkManager.openUrlInApp(url: webUrl, presenterViewController: self)
        }
    }

    @objc private func showUnclosedActionPopup(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let actionType = userInfo["actionType"] as? String,
           let title = userInfo["title"] as? String,
           let actionId = userInfo["actionId"] as? Int {

            let sb = UIStoryboard.init(name: StoryboardName.main, bundle: nil)
            if actionType == "solicitation" {
                if let vc = sb.instantiateViewController(withIdentifier: "ActionPasseOneDemand") as? ActionPasseOneDemand {
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.setContent(content: title)
                    vc.setActionId(id: actionId)
                    vc.setActionType(actionType: actionType)
                    self.present(vc, animated: true)
                }
            } else {
                if let vc = sb.instantiateViewController(withIdentifier: "ActionPassedOneContrib") as? ActionPassedOneContrib {
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.setContent(content: title)
                    vc.setActionId(id: actionId)
                    vc.setActionType(actionType: actionType)
                    self.present(vc, animated: true)
                }
            }
        }
    }
    // MARK: - WelcomeOneDelegate
    func onClickedLink() {
        AnalyticsLoggerManager.logEvent(name: Action_WelcomeOfferHelp_Day1)
        let storyboard = UIStoryboard(name: StoryboardName.pedagogic, bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "listPedagoNav") {
            self.navigationController?.present(vc, animated: true)
        }
    }

    // MARK: - WelcomeTwoDelegate
    func goMyGroup(id: Int, group: Neighborhood) {
        DeepLinkManager.showNeighborhoodDetailWithCreatePost(id: id, group: group)
    }

    func goGroupList() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNeighborhoodShowDiscover), object: nil)
    }

    // MARK: - MJAlertControllerDelegate
    func validateLeftButton(alertTag: MJAlertTAG) {
        let actionId = viewModel.userHome?.unclosedAction?.id

        DispatchQueue.main.async {
            let sb = UIStoryboard.init(name: StoryboardName.main, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "ActionPassedTwoVC") as? ActionPassedTwoVC {
                if let actionId = actionId {
                    vc.setActionId(id: actionId)
                }
                if let currentVc = AppState.getTopViewController() as? HomeViewController {
                    currentVc.present(vc, animated: true)
                }
            }
        }
    }

    func validateRightButton(alertTag: MJAlertTAG) {
        let actionType = viewModel.userHome?.unclosedAction?.actionType
        let actionId = viewModel.userHome?.unclosedAction?.id

        DispatchQueue.main.async {
            let sb = UIStoryboard.init(name: StoryboardName.main, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "ActionPassedOneVC") as? ActionPassedOneVC {
                if let actionId = actionId {
                    vc.setActionId(id: actionId)
                }
                if let actionType = actionType {
                    vc.setActionType(actionType: actionType)
                }
                if let currentVc = AppState.getTopViewController() as? HomeViewController {
                    currentVc.present(vc, animated: true)
                }
            }
        }
    }

    // MARK: - PlaceViewControllerDelegate
    func modifyPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        if let gplace = googlePlace, let placeId = gplace.placeID {
            UserService.updateUserAddressWith(placeId: placeId, isSecondaryAddress: false) { error in
                if error?.error == nil {
                }
            }
        }
    }

    // MARK: - Phase3fromAppDelegate
    func sendOnboardingEnd() {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let onboardingVC = storyboard.instantiateViewController(withIdentifier: "OnboardingEndViewController") as? OnboardingEndViewController {
            self.present(onboardingVC, animated: true, completion: nil)
        }
    }

    func updatePreference(userType: UserType) {
        var _user = UserDefaults.currentUser
        _user?.goal = userType.getGoalString()
        UserService.updateUser(user: _user) { user, error in
            SVProgressHUD.dismiss()
            if let user = user {
                UserDefaults.currentUser = user
            }
        }
    }

    func updateLoc(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        if let _place = googlePlace, let placeId = _place.placeID {
            UserService.updateUserAddressWith(placeId: placeId, isSecondaryAddress: false) { error in
                SVProgressHUD.dismiss()
            }
        }
    }

    // MARK: - NotificationDelegate
    func onEventLastDay(id: Int) {
        self.getEventAndLaunchPopup(eventId: String(id))
    }

    // MARK: - PopupBienCommunViewControllerDelegate
    func didVote() {
        if let url = URL(string: "https://bit.ly/3Z2tOB5") {
            WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: AppState.getTopViewController())
        }
    }

    // MARK: - Event Popup Logic
    private func getEventAndLaunchPopup(eventId: String) {
        EventService.getEventWithId(eventId) { [weak self] event, error in
            if let _event = event {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let eventLastDayVC = storyboard.instantiateViewController(withIdentifier: "eventLastDay") as? EventLastDayViewController {
                    eventLastDayVC.event = _event
                    eventLastDayVC.user = UserDefaults.currentUser
                    eventLastDayVC.modalPresentationStyle = .overCurrentContext
                    self?.present(eventLastDayVC, animated: true, completion: nil)
                }
            }
        }
    }

    // MARK: - Home Entry Gating
    private func runHomeEntryGatingIfNeeded() {
        guard !hasRunEntryGating else { return }
        hasRunEntryGating = true

        if let ad = UIApplication.shared.delegate as? AppDelegate {
            if ad.homeEntryGatingDidPresentCriticalThisSession ||
                ad.homeEntryGatingDidPresentNotifThisSession ||
                ad.homeEntryGatingDidPresentEnhancedThisSession {
                return
            }
        }

        guard let user = UserDefaults.currentUser else { return }

        let prefill = makeZonePrefillFromCurrentUser()
        let missingRole = !userHasRole(user)
        let missingZone = !userHasZone(user)

        if missingRole || missingZone {
            if missingRole {
                if let ad = UIApplication.shared.delegate as? AppDelegate {
                    ad.homeEntryGatingDidPresentCriticalThisSession = true
                }
                presentPhase3Onboarding()
                return
            }

            if missingZone {
                if let ad = UIApplication.shared.delegate as? AppDelegate {
                    ad.homeEntryGatingDidPresentCriticalThisSession = true
                }
                presentZoneChoice(prefill: prefill)
                return
            }
        }

        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let ad = UIApplication.shared.delegate as? AppDelegate {
                    if ad.homeEntryGatingDidPresentCriticalThisSession ||
                        ad.homeEntryGatingDidPresentNotifThisSession ||
                        ad.homeEntryGatingDidPresentEnhancedThisSession {
                        return
                    }
                }

                if settings.authorizationStatus != .authorized && settings.authorizationStatus != .provisional {
                    let notifPopupAlreadyShown = UserDefaults.standard.bool(forKey: "hasPresentedNotificationDemand")
                    if !notifPopupAlreadyShown {
                        UserDefaults.standard.set(true, forKey: "hasPresentedNotificationDemand")
                        UserDefaults.standard.synchronize()
                        if let ad = UIApplication.shared.delegate as? AppDelegate {
                            ad.homeEntryGatingDidPresentNotifThisSession = true
                        }
                        self.presentNotificationDemandViewController()
                        return
                    }
                }

                let needsEO = self.userNeedsEnhancedOnboarding(user)
                let hasEO = self.hasLaunchedEnhancedOnboarding()

                if !hasEO && needsEO {
                    if let ad = UIApplication.shared.delegate as? AppDelegate {
                        ad.homeEntryGatingDidPresentEnhancedThisSession = true
                    }
                    self.markEnhancedOnboardingLaunched()
                    self.presentEnhancedOnboardingIntro()
                    return
                }
            }
        }
    }

    private func presentPhase3Onboarding() {
        let sb = UIStoryboard(name: StoryboardName.onboarding, bundle: nil)
        if let onboardingStart = sb.instantiateViewController(withIdentifier: "onboardingStart") as? OnboardingStartViewController {
            onboardingStart.currentPhasePosition = 3
            onboardingStart.shouldLaunchThird = true
            if let u = UserDefaults.currentUser {
                onboardingStart.temporaryUser = u
            }
            onboardingStart.modalPresentationStyle = .fullScreen
            if presentedViewController != nil { dismiss(animated: false) }
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = onboardingStart
                window.makeKeyAndVisible()
            } else {
                present(onboardingStart, animated: true)
            }
        }
    }

    private func presentZoneChoice(prefill: ZonePrefill) {
        presentZoneChoiceSwiftUI(
            initialCoordinate: prefill.coordinate,
            initialLabel: prefill.label,
            initialRadiusKm: prefill.radiusKm,
            nextStep: .onboardingEnd,
            onConfirm: { _ in },
            onCancel: { }
        )
    }

    private func presentNotificationDemandViewController() {
        let sb = UIStoryboard(name: "PreOnboarding", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "NotificationDemandVC") as? NotificationDemandViewController {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }

    private func presentEnhancedOnboardingIntro() {
        let sb = UIStoryboard(name: "EnhancedOnboarding", bundle: nil)
        if let intro = sb.instantiateViewController(withIdentifier: "enhancedOnboardingIntro") as? EnhancedOnboardingIntro {
            intro.modalPresentationStyle = .fullScreen
            if presentedViewController != nil { dismiss(animated: false) }
            present(intro, animated: true)
        }
    }

    private func logEntryGating(_ message: String) {
        print("[HomeEntryGating] \(message)")
    }

    struct ZonePrefill {
        var coordinate: CLLocationCoordinate2D?
        var label: String?
        var radiusKm: Int
    }

    private func makeZonePrefillFromCurrentUser() -> ZonePrefill {
        guard let user = UserDefaults.currentUser,
              let address = user.addressPrimary else {
            return ZonePrefill(coordinate: nil, label: nil, radiusKm: 40)
        }
        let coord = CLLocationCoordinate2D(latitude: address.latitude, longitude: address.longitude)
        return ZonePrefill(coordinate: coord, label: address.displayAddress, radiusKm: 40)
    }

    private func userHasRole(_ user: User) -> Bool {
        return (user.goal != nil && !user.goal!.isEmpty)
    }

    private func userHasZone(_ user: User) -> Bool {
        return (user.addressPrimary != nil)
    }

    private func userNeedsEnhancedOnboarding(_ user: User) -> Bool {
        let interestsEmpty = (user.interests?.isEmpty ?? true)
        let involvementsEmpty = (user.involvements?.isEmpty ?? true)
        let concernsEmpty = (user.concerns?.isEmpty ?? true)
        return interestsEmpty || involvementsEmpty || concernsEmpty
    }

    private func hasLaunchedEnhancedOnboarding() -> Bool {
        return UserDefaults.standard.bool(forKey: "hasLaunchedEnhancedOnboarding")
    }

    private func markEnhancedOnboardingLaunched() {
        UserDefaults.standard.set(true, forKey: "hasLaunchedEnhancedOnboarding")
        UserDefaults.standard.synchronize()
    }
}
