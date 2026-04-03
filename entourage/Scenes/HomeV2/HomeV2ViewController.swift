//
//  HomeV2ViewController.swift
//  entourage
//
//  Created by Clement entourage on 20/09/2023.
//

import Foundation
import UIKit
import SafariServices
import SVProgressHUD
import CoreLocation
import GooglePlaces
import FirebaseMessaging
import SwiftUI

class HomeV2ViewController: UIViewController {
    
    // OUTLETS (Maintained to prevent Storyboard crashes)
    @IBOutlet weak var ui_drivable_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_drivable_table_view_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_table_view: UITableView!
    @IBOutlet weak var ui_button_notif: UIButton!
    @IBOutlet weak var ui_view_notif: UIView!
    @IBOutlet weak var ui_image_notif: UIImageView!
    @IBOutlet weak var ui_image_user_avatar: UIImageView!
    @IBOutlet weak var ui_label_subtitle: UILabel!

    // MARK: - Properties
    var viewModel = HomeV2ViewModel()
    private var hostingController: UIHostingController<HomeV2View>?

    // VARIABLES FOR GATING & OTHER COMPATIBILITY
    private var hasRunEntryGating = false
    private var hasShownCompletionStateThisSession = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        SVProgressHUD.show()
        AnalyticsLoggerManager.logEvent(name: View__Home)
        if EnhancedOnboardingConfiguration.shared.shouldNotDisplayCampain == true {
        } else {
            AnalyticsLoggerManager.logEvent(name: home_activate_firebase_message)
        }
        
        setupSwiftUIView()
        setupViewModelCallbacks()
        setupDataBindings()
        checkAndCreateCookieIfNotExists()

        SVProgressHUD.dismiss()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure celebration popup fires if fully completed and not shown
        if viewModel.welcomeJourneyViewModel.isFullyCompleted && !hasShownCompletionStateThisSession {
            let hasShownCelebration = UserDefaults.standard.bool(forKey: "hasShownWelcomeCelebration")
            if !hasShownCelebration {
                UserDefaults.standard.set(true, forKey: "hasShownWelcomeCelebration")
                self.hasShownCompletionStateThisSession = true

                DispatchQueue.main.async {
                    let celebrationVC = WelcomeJourneyCelebrationPopupViewController()
                    celebrationVC.modalPresentationStyle = .overFullScreen
                    celebrationVC.modalTransitionStyle = .crossDissolve
                    celebrationVC.onDismiss = { [weak self] in
                        self?.viewModel.loadData()
                    }
                    self.present(celebrationVC, animated: true)
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadData()
        self.checkForUpdates()
        self.ifEventLastDay()
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            print("Bundle Identifier: \(bundleIdentifier)")
        }
    }
    
    // Add logic bindings here that update the view or run checks when data loads
    private func setupDataBindings() {
        // Here we could use Combine to listen to viewModel, but since we are relying
        // on UIHostingController for the UI, we only need to catch the "data loaded" signal
        // for handling side-effects like onboarding return.
        // A simple approach since we know getDemandes is the last call in the chain
        // is to add a completion block or use the viewModel's objectWillChange.

        viewModel.onDataLoaded = { [weak self] in
            DispatchQueue.main.async {
                self?.handleEnhancedOnboardingReturn()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runHomeEntryGatingIfNeeded()
    }
    
    // MARK: - SwiftUI Integration
    private func setupSwiftUIView() {
        let homeView = HomeV2View(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: homeView)
        self.hostingController = hostingController

        addChild(hostingController)
        view.addSubview(hostingController.view)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        hostingController.didMove(toParent: self)
    }

    // MARK: - Callbacks
    private func setupViewModelCallbacks() {
        viewModel.onAvatarClick = { [weak self] in
            self?.onAvatarClick()
        }

        viewModel.onNotifClick = { [weak self] in
            self?.onNotifClick()
        }

        viewModel.onSeeAllDemands = { [weak self] in
            if self?.viewModel.isContributionPreference == true {
                AnalyticsLoggerManager.logEvent(name: Action_Home_Contrib_All)
                DeepLinkManager.showContribListUniversalLink()
            } else {
                AnalyticsLoggerManager.logEvent(name: Action_Home_Demand_All)
                DeepLinkManager.showDemandListUniversalLink()
            }
        }

        viewModel.onSeeAllEvents = {
            AnalyticsLoggerManager.logEvent(name: Action_Home_Event_All)
            DeepLinkManager.showOutingListUniversalLink()
        }

        viewModel.onSeeAllGroups = {
            AnalyticsLoggerManager.logEvent(name: Action_Home_Group_All)
            DeepLinkManager.showNeiborhoodListUniversalLink()
        }

        viewModel.onSeeAllPedagos = {
            AnalyticsLoggerManager.logEvent(name: Action__Home__Pedago)
            DeepLinkManager.showRessourceListUniversalLink()
        }

        viewModel.onMapClick = { [weak self] in
            AnalyticsLoggerManager.logEvent(name: Action__Home__Map)
            self?.showAllPois()
        }

        viewModel.onShowPedagogic = { [weak self] pedago in
            AnalyticsLoggerManager.logEvent(name: Action_Home_Article)
            self?.showPedagogic(pedagogic: pedago)
        }

        viewModel.onShowEvent = { [weak self] event in
            self?.showEvent(eventId: event.uid)
        }

        viewModel.onShowGroup = { [weak self] group in
            self?.showNeighborhood(neighborhoodId: group.uid)
        }

        viewModel.onShowAction = { [weak self] action, isContrib in
            if isContrib {
                AnalyticsLoggerManager.logEvent(name: Action_Home_Contrib_Detail)
            } else {
                AnalyticsLoggerManager.logEvent(name: Action_Home_Demand_Detail)
            }
            self?.showAction(actionId: action.id, isContrib: isContrib, action: action)
        }

        viewModel.onModeratorClick = { id in
            AnalyticsLoggerManager.logEvent(name: Action__Home__Moderator)
            MessagingService.createOrGetConversation(userId: String(id)) { conversation, error in
                if let conversation = conversation {
                    DeepLinkManager.showConversation(conversationId: conversation.uid)
                }
            }
        }

        viewModel.onGoBuffet = { [weak self] in
            AnalyticsLoggerManager.logEvent(name: Action_Home_Buffet)
            let urlStr = "https://reseauentourage.notion.site/Buffet-du-lien-social-69c20e089dbd483cb093e90ae2953a54"
            if let webUrl = URL(string: urlStr) {
                WebLinkManager.openUrlInApp(url: webUrl, presenterViewController: self)
            }
        }

        viewModel.onSolidarityEthicsTapped = { [weak self] in
            let isProd = EnvironmentConfigurationManager.sharedInstance.runsOnProduction
            let urlString = isProd ? "https://www.entourage.social/app/resources/eMU_InNSSJbE" : "https://preprod.entourage.social/app/resources/87203debda8b"
            if let _url = URL(string: urlString) {
                WebLinkManager.openUrl(url: _url, openInApp: true, presenterViewController: AppState.getTopViewController())
            }
        }

        viewModel.onWelcomeJourneyStepTapped = { [weak self] stepType in
            self?.handleWelcomeJourneyStep(stepType)
        }

        viewModel.onShowUnclosedActionPopup = { [weak self] actionType, title, actionId in
            self?.showPopUpAction(actionType: actionType, title: title, actionId: actionId)
        }

        viewModel.onTalkTapped = { [weak self] request in
            let sb = UIStoryboard(name: StoryboardName.messages, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController,
               let smalltalkId = request.smalltalk_id {

                let smalltalkIdString = String(smalltalkId)
                vc.setupFromOtherVC(conversationId: smalltalkId, title: "Bonnes ondes", isOneToOne: true, conversation: nil)
                vc.isSmallTalkMode = true
                vc.smallTalkId = smalltalkIdString
                self?.present(vc, animated: true)
            }
        }

        viewModel.onCreateSmallTalkTapped = { [weak self] in
            let storyboard = UIStoryboard(name: "SmallTalk", bundle: nil)
            guard let vc = storyboard.instantiateInitialViewController() else { return }
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true)
        }
    }

    func showPopUpAction(actionType: String, title: String, actionId: Int?) {
        AnalyticsLoggerManager.logEvent(name: View__StateDemandPop__Day10)

        let sb = UIStoryboard.init(name: StoryboardName.main, bundle: nil)
        if actionType == "solicitation" {
            if let vc = sb.instantiateViewController(withIdentifier: "ActionPasseOneDemand") as? ActionPasseOneDemand {
                vc.setContent(content: title)
                vc.setActionId(actionId: actionId)
                vc.setActionType(actionType: actionType)
                self.present(vc, animated: true)
            }
        }
        if actionType == "contribution" {
            if let vc = sb.instantiateViewController(withIdentifier: "ActionPassedOneContrib") as? ActionPassedOneContrib {
                vc.setContent(content: title)
                vc.setActionId(actionId: actionId)
                vc.setActionType(actionType: actionType)
                self.present(vc, animated: true)
            }
        }
    }

    // MARK: - Logic functions
    func onAvatarClick() {
        AnalyticsLoggerManager.logEvent(name: Action__Tab__Profil)
        let navVC = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil).instantiateViewController(withIdentifier: "profileFull")
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
    }

    func onNotifClick() {
        AnalyticsLoggerManager.logEvent(name: Action__Home__Notif)
        if let navVC = UIStoryboard.init(name: StoryboardName.main, bundle: nil).instantiateViewController(withIdentifier: "notifsNav") as? UINavigationController {
            navVC.modalPresentationStyle = .fullScreen
            if let vc = navVC.topViewController as? NotificationsInAppViewController {
                vc.hasToShowDot = viewModel.notificationCount > 0
                vc.delegate = self
            }
            self.tabBarController?.present(navVC, animated: true)
        }
    }

    private func handleWelcomeJourneyStep(_ stepType: WelcomeJourneyStepType) {
        switch stepType {
        case .video:
            let modalVC = WelcomeVideoModalViewController()
            modalVC.modalPresentationStyle = .overFullScreen
            modalVC.modalTransitionStyle = .crossDissolve
            modalVC.onComplete = { [weak self] in
                self?.viewModel.loadData()
            }
            modalVC.onDismissOnly = { [weak self] in
                self?.viewModel.loadData()
            }
            self.present(modalVC, animated: true)

        case .webinar:
            let vc = WelcomeEventsListViewController()
            vc.eventType = .firstStep
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)

        case .papotages:
            let vc = WelcomeEventsListViewController()
            vc.eventType = .papotages
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }

    func showVotePopupIfNeeded() {
        let userDefaults = UserDefaults.standard
        let hasSeenVotePopup = userDefaults.bool(forKey: "hasSeenVotePopup")

        guard !hasSeenVotePopup else { return }

        userDefaults.set(true, forKey: "hasSeenVotePopup")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let popupVC = storyboard.instantiateViewController(withIdentifier: "popupbiencommun") as? PopupBienCommunViewController {
            popupVC.delegate = self
            popupVC.modalPresentationStyle = .overCurrentContext
            self.present(popupVC, animated: true, completion: nil)
        }
    }

    func showAction(actionId: Int, isContrib: Bool, isAfterCreation: Bool = false, action: Action? = nil) {
        DeepLinkManager.showAction(id: actionId, isContrib: isContrib)
    }

    func showPedagogic(pedagogic: PedagogicResource) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "pedagoDetailVC") as? PedagogicDetailViewController {
            vc.urlWebview = pedagogic.url
            vc.resourceId = pedagogic.id
            vc.isRead = pedagogic.isRead
            vc.htmlBody = pedagogic.bodyHtml
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func showAllPois() {
        let sb = UIStoryboard.init(name: StoryboardName.solidarity, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "MainGuide") as? MainGuideViewController {
            vc.isFromDeeplink = true
            let navVc = UINavigationController()
            navVc.modalPresentationStyle = .fullScreen
            navVc.addChild(vc)
            self.navigationController?.present(navVc, animated: true)
        }
    }

    func showEvent(eventId: Int, isAfterCreation: Bool = false, event: Event? = nil) {
        if let navVc = UIStoryboard.init(name: StoryboardName.event, bundle: nil).instantiateViewController(withIdentifier: "eventDetailNav") as? UINavigationController, let vc = navVc.topViewController as? EventDetailFeedViewController {
            vc.eventId = eventId
            vc.event = event
            vc.isAfterCreation = isAfterCreation
            vc.modalPresentationStyle = .fullScreen
            self.tabBarController?.present(navVc, animated: true, completion: nil)
            return
        }
    }

    func showNeighborhood(neighborhoodId: Int, isAfterCreation: Bool = false, isShowCreatePost: Bool = false, neighborhood: Neighborhood? = nil) {
        let sb = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil)
        if let nav = sb.instantiateViewController(withIdentifier: "neighborhoodDetailNav") as? UINavigationController, let vc = nav.topViewController as? NeighborhoodDetailViewController {
            vc.isAfterCreation = isAfterCreation
            vc.neighborhoodId = neighborhoodId
            vc.isShowCreatePost = isShowCreatePost
            vc.neighborhood = neighborhood
            self.navigationController?.present(nav, animated: true)
        }
    }

    func checkAndCreateCookieIfNotExists() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "isTranslatedByDefault") == nil {
            defaults.set(true, forKey: "isTranslatedByDefault")
        }
    }

    func showResources() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "listPedagoNav") {
            self.navigationController?.present(vc, animated: true)
        }
    }

    func showNeighborhoodDetailWithCreatePost(id: Int, group: Neighborhood) {
        DeepLinkManager.showNeighborhoodDetailWithCreatePost(id: id, group: group)
    }

    func showAllNeighborhoods() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNeighborhoodShowDiscover), object: nil)
    }

    func ifEventLastDay() {
        if let _eventId = viewModel.shouldLaunchEventPopup {
            self.getEventAndLaunchPopup(eventId: String(_eventId))
            viewModel.shouldLaunchEventPopup = nil
        }
    }

    func getEventAndLaunchPopup(eventId: String) {
        EventService.getEventWithId(eventId) { event, error in
            if let _event = event {
                self.launchEventLastDayVC(with: _event)
            }
        }
    }

    func sendDiscussionSmokeTest() {
        let discussionSmokeCount = UserDefaults.standard.integer(forKey: "discussionSmokeCount")
        UserDefaults.standard.set(discussionSmokeCount + 1, forKey: "discussionSmokeCount")
        
        if discussionSmokeCount >= 1 {
            let hasDeniedDiscussion = UserDefaults.standard.bool(forKey: "HasDeniedDiscussion")
            let hasAcceptedDiscussion = UserDefaults.standard.bool(forKey: "HasAcceptedDiscussion")
            
            if !hasDeniedDiscussion && !hasAcceptedDiscussion {
                let sb = UIStoryboard.init(name: StoryboardName.main, bundle: nil)
                if let vc = sb.instantiateViewController(withIdentifier: "DiscussionSmokeTestViewController") as? DiscussionSmokeTestViewController {
                    if let currentVc = AppState.getTopViewController() {
                        currentVc.present(vc, animated: true)
                    }
                }
            }
        }
    }
    
    func handleEnhancedOnboardingReturn() {
        let config = EnhancedOnboardingConfiguration.shared
        if config.shouldSendOnboardingFromNormalWay {
            SVProgressHUD.dismiss()
            self.sendOnboardingIntro()
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
    
    func sendOnboardingIntro() {
        let storyboard = UIStoryboard(name: "EnhancedOnboarding", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "enhancedOnboardingIntro") as? EnhancedOnboardingIntro {
            let config = EnhancedOnboardingConfiguration.shared
            if viewModel.isContributionPreference {
                config.preference = "contribution"
            }
            
            config.shouldSendOnboardingFromNormalWay = false
            config.isFromOnboardingFromNormalWay = true
            viewController.isAssociationGoal = self.viewModel.userHome.association ?? false
            viewController.modalPresentationStyle = .fullScreen
            viewController.modalTransitionStyle = .coverVertical
            present(viewController, animated: true, completion: nil)
        }
    }

    private func launchEventLastDayVC(with event: Event) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let eventLastDayVC = storyboard.instantiateViewController(withIdentifier: "eventLastDay") as? EventLastDayViewController {
            eventLastDayVC.event = event
            eventLastDayVC.user = viewModel.currentUser
            eventLastDayVC.modalPresentationStyle = .overCurrentContext
            self.present(eventLastDayVC, animated: true, completion: nil)
        }
    }
    
    func checkForUpdates() {
        let appStoreURL = URL(string: "http://itunes.apple.com/lookup?bundleId=social.entourage.entourage")!
        let task = URLSession.shared.dataTask(with: appStoreURL) { (data, response, error) in
            guard error == nil, let data = data else { return }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let appStoreVersion = results.first?["version"] as? String,
                   let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
                   appStoreVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
                    
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Mise à jour disponible",
                                                      message: "Une nouvelle version de l'application est disponible. Voulez-vous mettre à jour ?",
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Mettre à jour", style: .default, handler: { _ in
                            if let url = URL(string: "itms-apps://itunes.apple.com/app/idYOUR_APP_ID"),
                               UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }))
                        alert.addAction(UIAlertAction(title: "Plus tard", style: .cancel, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
            } catch {
                print("Erreur lors de la vérification de la mise à jour de l'application : \(error)")
            }
        }
        task.resume()
    }
    
    func presentNotificationDemandViewController() {
        if NotificationDisplayManager.shared.hasBeenDisplayed == false {
            NotificationDisplayManager.shared.hasBeenDisplayed = true
            let storyboard = UIStoryboard(name: StoryboardName.onboarding, bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "NotificationDemandViewController") as? NotificationDemandViewController {
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true, completion: nil)
            } else {
                print("ViewController with identifier 'NotificationDemandViewController' not found")
            }
        }
    }

}

// MARK: - NotificationDelegate
extension HomeV2ViewController: NotificationDelegate {
    func onEventLastDay(id: Int) {
        self.getEventAndLaunchPopup(eventId: String(id))
    }
}

// MARK: - PopupBienCommunViewControllerDelegate
extension HomeV2ViewController: PopupBienCommunViewControllerDelegate {
    func didVote() {
        if let url = URL(string: "https://bit.ly/3Z2tOB5") {
            WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: AppState.getTopViewController())
        }
    }
}

// MARK: - SFSafariViewControllerDelegate
extension HomeV2ViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    }
}

// MARK: - Welcome Delegates
extension HomeV2ViewController: WelcomeOneDelegate {
    func onClickedLink() {
        AnalyticsLoggerManager.logEvent(name: Action_WelcomeOfferHelp_Day1)
        showResources()
    }
}

extension HomeV2ViewController: WelcomeTwoDelegate {
    func goMyGroup(id: Int, group: Neighborhood) {
        showNeighborhoodDetailWithCreatePost(id: id, group: group)
    }
    
    func goGroupList() {
        self.showAllNeighborhoods()
    }
}

extension HomeV2ViewController: WelcomeThreeDelegate {
}

// MARK: - MJAlertControllerDelegate
extension HomeV2ViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag: MJAlertTAG) {
        let actionId = self.viewModel.userHome.unclosedAction?.id
        
        DispatchQueue.main.async {
            let sb = UIStoryboard.init(name: StoryboardName.main, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "ActionPassedTwoVC") as? ActionPassedTwoVC {
                if actionId != nil {
                    vc.setActionId(id: actionId!)
                }
                if let currentVc = AppState.getTopViewController() as? HomeV2ViewController {
                    currentVc.present(vc, animated: true)
                }
            }
        }
    }
    
    func validateRightButton(alertTag: MJAlertTAG) {
        let actionType = self.viewModel.userHome.unclosedAction?.actionType!
        let actionId = self.viewModel.userHome.unclosedAction?.id
        DispatchQueue.main.async {
            let sb = UIStoryboard.init(name: StoryboardName.main, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "ActionPassedOneVC") as? ActionPassedOneVC {
                if actionId != nil {
                    vc.setActionId(id: actionId!)
                }
                if actionType != nil {
                    vc.setActionType(actionType: actionType!)
                }
                if let currentVc = AppState.getTopViewController() as? HomeV2ViewController {
                    currentVc.present(vc, animated: true)
                }
            }
        }
    }
}

// MARK: - PlaceViewControllerDelegate
extension HomeV2ViewController: PlaceViewControllerDelegate {
    func modifyPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        if let gplace = googlePlace, let placeId = gplace.placeID {
            UserService.updateUserAddressWith(placeId: placeId, isSecondaryAddress: false) { error in
            }
        }
    }
}

// MARK: - SimpleAlertClick
extension HomeV2ViewController: SimpleAlertClick {
    func onClickMainButton() {
        let sb = UIStoryboard(name: "ProfileParams", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "place_choose_vc") as? ParamsChoosePlaceViewController {
            vc.placeVCDelegate = self
            self.navigationController?.present(vc, animated: true)
        }
    }
}

// MARK: - Phase3fromAppDelegate
extension HomeV2ViewController: Phase3fromAppDelegate {
    func sendOnboardingEnd() {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let onboardingVC = storyboard.instantiateViewController(withIdentifier: "OnboardingEndViewController") as? OnboardingEndViewController {
            self.present(onboardingVC, animated: true, completion: nil)
        }
    }
    
    func updatePreference(userType: UserType) {
        var _user = viewModel.currentUser
        _user?.goal = userType.getGoalString()
        UserService.updateUser(user: _user) { [weak self] user, error in
            SVProgressHUD.dismiss()
            if let user = user {
                self?.viewModel.currentUser = user
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
}

// MARK: - AppManager
class AppManager {
    static let shared = AppManager()
    var isContributionPreference: Bool = false
    private init() {}
}

// MARK: - Entry Gating Logic
extension HomeV2ViewController {
    
    private struct ZonePrefill {
        let coordinate: CLLocationCoordinate2D?
        let label: String?
        let radiusKm: Int
    }
    
    private var appDelegate: AppDelegate? {
        UIApplication.shared.delegate as? AppDelegate
    }
    
    private func makeZonePrefillFromCurrentUser() -> ZonePrefill {
        guard let user = UserDefaults.currentUser else {
            return ZonePrefill(coordinate: nil, label: nil, radiusKm: 20)
        }
        
        let radius = max(1, user.radiusDistance ?? 20)
        var coord: CLLocationCoordinate2D? = nil
        var label: String? = nil
        
        if let addr = user.addressPrimary {
            if let lat = addr.latitude, let lon = addr.longitude {
                coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
            if let l = addr.displayAddress, !l.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                label = l
            }
        }
        
        return ZonePrefill(coordinate: coord, label: label, radiusKm: radius)
    }
    
    private func userHasRole(_ user: User) -> Bool {
        let g = (user.goal ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return !g.isEmpty
    }
    
    private func userHasZone(_ user: User) -> Bool {
        user.addressPrimary != nil
    }
    
    private func userNeedsEnhancedOnboarding(_ user: User) -> Bool {
        let interestsEmpty = (user.interests?.isEmpty ?? true)
        let involvementsEmpty = (user.involvements?.isEmpty ?? true)
        let concernsEmpty = (user.concerns?.isEmpty ?? true)
        return interestsEmpty || involvementsEmpty || concernsEmpty
    }
    
    private func hasLaunchedEnhancedOnboarding() -> Bool {
        UserDefaults.standard.bool(forKey: "hasLaunchedEnhancedOnboarding")
    }
    
    private func markEnhancedOnboardingLaunched() {
        UserDefaults.standard.set(true, forKey: "hasLaunchedEnhancedOnboarding")
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
            if presentedViewController != nil {
                dismiss(animated: false)
            }
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
            onConfirm: { [weak self] result in
                print("ZoneChoice confirm")
            },
            onCancel: {
                print("ZoneChoice cancel")
            }
        )
    }
    
    private func presentEnhancedOnboardingIntro() {
        let sb = UIStoryboard(name: "EnhancedOnboarding", bundle: nil)
        if let intro = sb.instantiateViewController(withIdentifier: "enhancedOnboardingIntro") as? EnhancedOnboardingIntro {
            if let _ = UserDefaults.currentUser?.partner {
                intro.isAssociationGoal = true
            }
            intro.modalPresentationStyle = .fullScreen
            if presentedViewController != nil {
                dismiss(animated: false)
            }
            present(intro, animated: true)
        }
    }
    
    func runHomeEntryGatingIfNeeded() {
        guard presentedViewController == nil else {
            return
        }
        
        guard !hasRunEntryGating else {
            return
        }
        hasRunEntryGating = true
        
        if let ad = UIApplication.shared.delegate as? AppDelegate {
            if ad.homeEntryGatingDidPresentCriticalThisSession ||
                ad.homeEntryGatingDidPresentNotifThisSession ||
                ad.homeEntryGatingDidPresentEnhancedThisSession {
                return
            }
        }
        
        guard let user = UserDefaults.currentUser else {
            return
        }
        
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
                guard self.presentedViewController == nil else { return }
                
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
}
