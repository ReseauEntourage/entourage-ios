//
//  HomeV2ViewController.swift
//  entourage
//
//  Created by Clement entourage on 20/09/2023.
//

import Foundation
import UIKit
import SafariServices
import IHProgressHUD
import CoreLocation
import GooglePlaces

enum seeAllCellType{
    case seeAllDemand
    case seeAllEvent
    case seeAllGroup
    case seeAllPedago
}

enum HomeV2DTO{
    case cellTitle(title:String, subtitle:String)
    case cellAction(action:Action)
    case cellSeeAll(seeAllType:seeAllCellType)
    case cellEvent(events:[Event])
    case cellGroup(groups:[Neighborhood])
    case cellPedago(pedago:PedagogicResource)
    case cellMap
    case cellIAmLost(helpType:HomeNeedHelpType)
    case moderator(name:String, imageUrl:String? = nil)
    case cellHZ
}

class HomeV2ViewController:UIViewController{
    
    //OUTLET
    
    @IBOutlet weak var ui_drivable_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_drivable_table_view_top_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var ui_table_view: UITableView!
    @IBOutlet weak var ui_button_notif: UIButton!
    @IBOutlet weak var ui_view_notif: UIView!
    @IBOutlet weak var ui_image_notif: UIImageView!
    @IBOutlet weak var ui_image_user_avatar: UIImageView!
    @IBOutlet weak var ui_label_subtitle: UILabel!
    
    //VARIABLE
    var tableDTO = [HomeV2DTO]()
    var notificationCount = 0
    var allGroups = [Neighborhood]()
    var allEvents = [Event]()
    var allDemands = [Action]()
    var allPedagos = [PedagogicResource]()
    
    var currentFilter = EventActionLocationFilters()
    var currentLocationFilter = EventActionLocationFilters()
    var currentSectionsFilter:Sections = Sections()
    var userHome:UserHome = UserHome()
    var currentUser:User? = nil

    var pedagoCreateEvent:PedagogicResource?
    var pedagoCreateGroup:PedagogicResource?
    var isContributionPreference = false
    var shouldLaunchEventPopup:Int? = nil
    var shouldGoEvent = false
    var shouldTestOnboarding = true
    
    override func viewDidLoad() {
        IHProgressHUD.show()
        currentUser = UserDefaults.currentUser
        AnalyticsLoggerManager.logEvent(name: View__Home)
        prepareUINotifAndAvatar()
        ui_table_view.delegate = self
        ui_table_view.dataSource = self
        ui_table_view.backgroundColor = UIColor(named: "white_orange_home")
        //Register cells
        //CELL TITLE
        ui_table_view.register(UINib(nibName: HomeV2CellTitle.identifier, bundle: nil), forCellReuseIdentifier: HomeV2CellTitle.identifier)
        //CELL SEE ALL
        ui_table_view.register(UINib(nibName: HomeSeeAllCell.identifier, bundle: nil), forCellReuseIdentifier: HomeSeeAllCell.identifier)
        //CELL MAP BUTTON
        ui_table_view.register(UINib(nibName: HomeCellMapButton.identifier, bundle: nil), forCellReuseIdentifier: HomeCellMapButton.identifier)
        //CELL ACTION
        ui_table_view.register(UINib(nibName: HomeCellAction.identifier, bundle: nil), forCellReuseIdentifier: HomeCellAction.identifier)
        //CELL EVENT
        ui_table_view.register(UINib(nibName: HomeEventHorizontalCollectionCell.identifier, bundle: nil), forCellReuseIdentifier: HomeEventHorizontalCollectionCell.identifier)
        //CELL GROUP
        ui_table_view.register(UINib(nibName: HomeGroupHorizontalCollectionCell.identifier, bundle: nil), forCellReuseIdentifier: HomeGroupHorizontalCollectionCell.identifier)
        //CELL PEDAGO
        ui_table_view.register(UINib(nibName: HomeCellPedago.identifier, bundle: nil), forCellReuseIdentifier: HomeCellPedago.identifier)
        //CELL HELP
        ui_table_view.register(UINib(nibName: HomeNeedHelpCell.identifier, bundle: nil), forCellReuseIdentifier: HomeNeedHelpCell.identifier)
        //CELL MODERATOR
        ui_table_view.register(UINib(nibName: HomeModeratorCell.identifier, bundle: nil), forCellReuseIdentifier: HomeModeratorCell.identifier)
        //CELL HZ
        ui_table_view.register(UINib(nibName: HomeHZCell.identifier, bundle: nil), forCellReuseIdentifier: HomeHZCell.identifier)
        self.checkAndCreateCookieIfNotExists()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentFilter.resetToDefault()
        self.loadMetadatas()

        self.initHome()
        self.checkForUpdates()
        self.ifEventLastDay()
        //self.testEventLastDay()
        if shouldTestOnboarding{
            shouldTestOnboarding = false
            self.sendOnboardingIntro()
        }
        if self.shouldGoEvent {
            if let _tabbar = self.tabBarController as? MainTabbarViewController {
                _tabbar.showDiscoverEvents()
            }
        }
    }
    
    //MARK: TODO REMOVE THIS
    func testEventLastDay(){
        getEventAndLaunchPopup(eventId: "136208")
    }
    
    func ifEventLastDay(){
        if let _eventId = shouldLaunchEventPopup{
            self.getEventAndLaunchPopup(eventId: String(_eventId))
            shouldLaunchEventPopup = nil
        }
    }
    
    func getEventAndLaunchPopup(eventId:String){
        EventService.getEventWithId(eventId) { event, error in
            if let _event = event {
                self.launchEventLastDayVC(with: _event)
            }
        }
    }
    
    func sendOnboardingIntro(){
        let storyboard = UIStoryboard(name: "EnhancedOnboarding", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "enhancedOnboardingIntro") as? EnhancedOnboardingIntro {
            viewController.modalPresentationStyle = .fullScreen
            viewController.modalTransitionStyle = .coverVertical
            present(viewController, animated: true, completion: nil)
        }
    }

    private func launchEventLastDayVC(with event: Event) {
           let storyboard = UIStoryboard(name: "Main", bundle: nil) // Remplacez "Main" par le nom de votre storyboard si nécessaire
           if let eventLastDayVC = storyboard.instantiateViewController(withIdentifier: "eventLastDay") as? EventLastDayViewController {
               eventLastDayVC.event = event
               eventLastDayVC.user = currentUser
               eventLastDayVC.modalPresentationStyle = .overCurrentContext
               self.present(eventLastDayVC, animated: true, completion: nil)
           }
       }
    
    func checkForUpdates() {
        let appStoreURL = URL(string: "http://itunes.apple.com/lookup?bundleId=social.entourage.entourage")!
        let task = URLSession.shared.dataTask(with: appStoreURL) { (data, response, error) in
            guard error == nil, let data = data else {
                return
            }

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
                        // Présenter l'alerte ici, par exemple avec self.present(alert, animated: true)
                    }
                }
            } catch {
                print("Erreur lors de la vérification de la mise à jour de l'application : \(error)")
            }
        }
        task.resume()
    }
    
    func prepareUINotifAndAvatar(){
        ui_view_notif.layer.cornerRadius = 18
        ui_view_notif.clipsToBounds = true
        ui_image_user_avatar.layer.cornerRadius = 18
        ui_image_user_avatar.clipsToBounds = true
        ui_button_notif.addTarget(self, action: #selector(onNotifClick), for: .touchUpInside)
        ui_image_user_avatar.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onAvatarClick))
        ui_image_user_avatar.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func onAvatarClick(){
        AnalyticsLoggerManager.logEvent(name: Action__Tab__Profil)
        let navVC = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil).instantiateViewController(withIdentifier: "mainNavProfile")
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
    }
    
    @objc func onNotifClick(){
        AnalyticsLoggerManager.logEvent(name: Action__Home__Notif)
        if let navVC = UIStoryboard.init(name: StoryboardName.main, bundle: nil).instantiateViewController(withIdentifier: "notifsNav") as? UINavigationController {
            navVC.modalPresentationStyle = .fullScreen
            if let vc = navVC.topViewController as? NotificationsInAppViewController {
                vc.hasToShowDot =  notificationCount > 0
            }
            self.tabBarController?.present(navVC, animated: true)
        }
    }
    
    func configureDTO(){
        self.tableDTO.removeAll()
        self.updateTopView()
        if(allDemands.count > 0){
            if isContributionPreference {
                tableDTO.append(.cellTitle(title: "home_v2_title_action_contrib".localized, subtitle: "home_v2_subtitle_action_contrib".localized))
                for demand in allDemands {
                    tableDTO.append(.cellAction(action: demand))
                }
                tableDTO.append(.cellSeeAll(seeAllType: .seeAllDemand))
            }else{
                tableDTO.append(.cellTitle(title: "home_v2_title_action".localized, subtitle: "home_v2_subtitle_action".localized))
                for demand in allDemands {
                    tableDTO.append(.cellAction(action: demand))
                }
                tableDTO.append(.cellSeeAll(seeAllType: .seeAllDemand))
            }
        }
        if allEvents.count > 0 {
            tableDTO.append(.cellTitle(title: "home_v2_title_event".localized, subtitle: "home_v2_subtitle_event".localized))
            tableDTO.append(.cellEvent(events: allEvents))
            tableDTO.append(.cellSeeAll(seeAllType: .seeAllEvent))
        }
        if allPedagos.count > 0 {
            tableDTO.append(.cellTitle(title: "home_v2_title_pedago".localized, subtitle: "home_v2_subtitle_pedago".localized))
            for pedago in allPedagos {
                tableDTO.append(.cellPedago(pedago: pedago))
            }
            tableDTO.append(.cellSeeAll(seeAllType: .seeAllPedago))
        }
        if allGroups.count > 0 {
            tableDTO.append(.cellTitle(title: "home_v2_title_group".localized, subtitle: "home_v2_subtitle_group".localized))
            tableDTO.append(.cellGroup(groups: allGroups))
            tableDTO.append(.cellSeeAll(seeAllType: .seeAllGroup))
        }
        
        tableDTO.append(.cellTitle(title: "home_v2_title_map".localized, subtitle: "home_v2_subtitle_map".localized))
        tableDTO.append(.cellMap)
        

        var _offlineEvents = [Event]()
        for event in allEvents{
            if event.isOnline == false {
                _offlineEvents.append(event)
            }
        }
        if _offlineEvents.count == 0 && allDemands.count == 0 && !isContributionPreference {
            tableDTO.append(.cellHZ)
        }
        tableDTO.append(.cellTitle(title: "home_v2_title_help".localized, subtitle: "home_v2_subtitle_help".localized))
        //tableDTO.append(.cellIAmLost(helpType: .createGroup))
        //tableDTO.append(.cellIAmLost(helpType: .createEvent))
        if let _moderator = userHome.moderator{
            if let _name = _moderator.displayName{
                tableDTO.append(.moderator(name: _name, imageUrl: _moderator.imgUrl))
            }
        }
        self.ui_table_view.reloadData()
        IHProgressHUD.dismiss()
    }
    func initHome(){
        self.ui_label_subtitle.text = "home_v2_title".localized
        self.getNotif()
        
    }
    func updateTopView() {
        
        if let _urlstr = userHome.avatarURL,  let url = URL(string: _urlstr) {
            ui_image_user_avatar.sd_setImage(with: url,placeholderImage: UIImage.init(named: "placeholder_user"))
        }
        else {
            ui_image_user_avatar.image = UIImage.init(named: "placeholder_user")
        }
        
        if notificationCount == 0 {
            self.ui_image_notif.image = UIImage(named: "ic_notif_off")
            self.ui_view_notif.backgroundColor = UIColor.white // Remplacez "partner_logo_background" par le nom de la couleur dans votre fichier Assets.xcassets.
        } else {
            self.ui_image_notif.image = UIImage(named: "ic_notif_on") // Assurez-vous que l'image "ic_white_notif_on" est disponible dans votre projet.
            self.ui_view_notif.backgroundColor = UIColor.appOrange // Utilisez la couleur orange que vous avez ajoutée précédemment.
        }
        prepareUINotifAndAvatar()
    }
    
    
}
extension HomeV2ViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDTO.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableDTO[indexPath.row]{
            
        case .cellTitle(let title, let subtitle):
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "HomeV2CellTitle") as? HomeV2CellTitle{
                cell.selectionStyle = .none
                cell.configure(title: title, subtitle: subtitle)
                return cell
            }
        case .cellAction(let action):
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "HomeCellAction") as? HomeCellAction{
                cell.selectionStyle = .none
                cell.configure(action: action)
                return cell
            }
        case .cellSeeAll(let seeAllType):
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "HomeSeeAllCell") as? HomeSeeAllCell{
                cell.selectionStyle = .none
                cell.configure(type: seeAllType,isContrib: self.isContributionPreference)
                return cell
            }
            
        case .cellEvent(let events):
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "HomeEventHorizontalCollectionCell") as? HomeEventHorizontalCollectionCell{
                cell.selectionStyle = .none
                cell.delegate = self
                cell.configure(events: events)
                return cell
            }
        case .cellGroup(let groups):
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "HomeGroupHorizontalCollectionCell") as? HomeGroupHorizontalCollectionCell{
                cell.selectionStyle = .none
                cell.delegate = self
                cell.configure(groups: groups)
                return cell
            }
        case .cellPedago(let pedago):
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "HomeCellPedago") as? HomeCellPedago{
                cell.selectionStyle = .none
                cell.configure(pedago: pedago)
                return cell
            }
        case .cellMap:
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "HomeCellMapButton") as? HomeCellMapButton{
                cell.selectionStyle = .none
                cell.configure(title: "home_v2_button_map".localized)
                return cell
            }
        case .cellIAmLost(let helpType):
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "HomeNeedHelpCell") as? HomeNeedHelpCell{
                cell.selectionStyle = .none
                cell.configure(homeNeedHelpType: helpType)
                return cell
            }
        case .moderator(let name, let imageUrl):
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "HomeModeratorCell") as? HomeModeratorCell{
                cell.selectionStyle = .none
                cell.configure(title: name, imageUrl: imageUrl)
                return cell
            }
        case .cellHZ:
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "HomeHZCell") as? HomeHZCell{
                cell.selectionStyle = .none
                cell.delegate = self
                return cell
            }
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableDTO[indexPath.row]{
        case .cellTitle(_,_):
            return
        case .cellAction(let action):
            if isContributionPreference {
                AnalyticsLoggerManager.logEvent(name: Action_Home_Contrib_Detail)
                self.showAction(actionId: action.id, isContrib: true, action: action)
            }else{
                AnalyticsLoggerManager.logEvent(name: Action_Home_Demand_Detail)
                self.showAction(actionId: action.id, isContrib: false, action: action)
            }
        case .cellSeeAll(let seeAllType):
            switch seeAllType{
            case .seeAllDemand:
                if isContributionPreference {
                    AnalyticsLoggerManager.logEvent(name: Action_Home_Contrib_All)
                    DeepLinkManager.showContribListUniversalLink()
                }else{
                    AnalyticsLoggerManager.logEvent(name: Action_Home_Demand_All)
                    DeepLinkManager.showDemandListUniversalLink()
                }
            case .seeAllEvent:
                AnalyticsLoggerManager.logEvent(name: Action_Home_Event_All)
                DeepLinkManager.showOutingListUniversalLink()
            case .seeAllGroup:
                AnalyticsLoggerManager.logEvent(name: Action_Home_Group_All)
                DeepLinkManager.showNeiborhoodListUniversalLink()
            case .seeAllPedago:
                AnalyticsLoggerManager.logEvent(name: Action__Home__Pedago)
                DeepLinkManager.showRessourceListUniversalLink()
            }
        case .cellEvent(_):
            return
        case .cellGroup(_):
            return
        case .cellPedago(let pedago):
            AnalyticsLoggerManager.logEvent(name: Action_Home_Article)
            showPedagogic(pedagogic: pedago)
        case .cellMap:
            AnalyticsLoggerManager.logEvent(name: Action__Home__Map)
            self.showAllPois()
        case .cellIAmLost(let helpType):
            switch helpType{
            case .createEvent:
                AnalyticsLoggerManager.logEvent(name: Action_Home_CreateEvent)
                showPedagogic(pedagogic: pedagoCreateEvent!)
            case .createGroup:
                AnalyticsLoggerManager.logEvent(name: Action_Home_CreateGroup)
                showPedagogic(pedagogic: pedagoCreateGroup!)
            }
        case .moderator(_,_):
            if let _moderator = self.userHome.moderator{
                AnalyticsLoggerManager.logEvent(name: Action__Home__Moderator)
                if let _id = _moderator.id{
                    showUserProfile(id: _id)
                }
            }
        case .cellHZ:
            AnalyticsLoggerManager.logEvent(name: Action_Home_Buffet)
            return
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableDTO[indexPath.row]{
        case .cellTitle(_,_):
            return UITableView.automaticDimension
        case .cellAction(_):
            return UITableView.automaticDimension
        case .cellSeeAll(_):
            return UITableView.automaticDimension
        case .cellEvent(_):
            return 215
        case .cellGroup(_):
            return 130
        case .cellPedago(_):
            return UITableView.automaticDimension
        case .cellMap:
            return UITableView.automaticDimension
        case .cellIAmLost(_):
            return UITableView.automaticDimension
        case .moderator(_,_):
            return UITableView.automaticDimension
        case .cellHZ:
            return UITableView.automaticDimension
        }
    }
}


//MARK: Here all call to API
extension HomeV2ViewController{
    func getNotif(){
        HomeService.getNotificationsCount { count, error in
            self.notificationCount = count ?? 0
            self.getMyGroups()
        }
    }
    func getDemandes(){
        if isContributionPreference {
            ActionsService.getAllActions(isContrib: true, currentPage: 1, per: 3, filtersLocation: currentLocationFilter.getfiltersForWS(), filtersSections: currentSectionsFilter.getallSectionforWS()) { actions, error in
                if let actions = actions {
                    self.allDemands.removeAll()
                    self.allDemands.append(contentsOf: actions)
                }
                self.configureDTO()
            }
        }else{
            ActionsService.getAllActions(isContrib: false, currentPage: 1, per: 3, filtersLocation: currentLocationFilter.getfiltersForWS(), filtersSections: currentSectionsFilter.getallSectionforWS()) { actions, error in
                if let actions = actions {
                    self.allDemands.removeAll()
                    self.allDemands.append(contentsOf: actions)
                }
                self.configureDTO()
            }
        }
    }
    
    func getMyGroups(){
        guard let token = UserDefaults.currentUser?.uuid else { return }
        NeighborhoodService.getNeighborhoodsForUserId(token,currentPage: 1, per: 10, completion: { groups, error in
            if let groups = groups {
                self.allGroups.removeAll()
                self.allGroups.append(contentsOf: groups)
            }
            self.getEvents()
        })
    }
    func getEvents(){
    EventService.getAllEventsDiscover(currentPage: 1, per: 10, filters: currentFilter.getfiltersForWS()) { events, error in
            if let events = events {
                self.allEvents.removeAll()
                self.allEvents.append(contentsOf: events)
            }
        self.getPedago()
        }
    }

    
    func getPedago(){
        HomeService.getResources { resources, error in
            if let resources = resources {
                self.allPedagos.removeAll()
                var pedagoReads = [PedagogicResource]()
                for resource in resources {
                    if resource.isRead == false{
                        pedagoReads.append(resource)
                    }
                }
                for pedagoRead in pedagoReads {
                    self.allPedagos.append(pedagoRead)
                    if self.allPedagos.count > 1{
                        break
                    }
                }
                #if DEBUG
                for pedago in resources{
                    if pedago.id == 32{
                        self.pedagoCreateEvent = pedago
                    }else if pedago.id == 33{
                        self.pedagoCreateGroup = pedago
                    }
                }
                #else
                for pedago in resources{
                    if pedago.id == 15{
                        self.pedagoCreateEvent = pedago
                    }else if pedago.id == 37{
                        self.pedagoCreateGroup = pedago
                    }
                }
                #endif
            }
            self.getHomeDetail()
        }
    }
    func getHomeDetail() {
        HomeService.getUserHome { [weak self] userHome, error in
            if let userHome = userHome {
                self?.userHome = userHome
                if userHome.preference == "contribution" {
                    self?.isContributionPreference = true
                }else{
                    self?.isContributionPreference = false
                }
                
                if UserDefaults.currentUser?.addressPrimary == nil
                    || userHome.preference == nil {
                    // Obtenir la storyboard nommée "Onboarding"
                    let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
                    
                    // Instancier le OnboardingPageViewController à partir de la storyboard
                    if let onboardingPageVC = storyboard.instantiateViewController(withIdentifier: "onboardingStart") as? OnboardingStartViewController {
                        onboardingPageVC.currentPhasePosition = 3
                        onboardingPageVC.shouldLaunchThird = true
                        if let _user = UserDefaults.currentUser {
                            onboardingPageVC.temporaryUser = _user
                        }
                        if let window = UIApplication.shared.windows.first {
                            window.rootViewController = onboardingPageVC
                            window.makeKeyAndVisible()
                        }
                    }
                }
                
                AppManager.shared.isContributionPreference = self?.isContributionPreference ?? false

                if  userHome.unclosedAction != nil {
                    self?.showPopUpAction(actionType: (userHome.unclosedAction?.actionType)!, title: (userHome.unclosedAction?.title)!)
                }
            }

            self?.getDemandes()
        }
    }
     func loadMetadatas() {
        MetadatasService.getMetadatas { error in
            Logger.print("***** return get metadats ? \(error)")
        }
    }
    
    func showPopUpAction(actionType:String, title:String) {
        let actionId = self.userHome.unclosedAction?.id
        AnalyticsLoggerManager.logEvent(name: View__StateDemandPop__Day10)

        let sb = UIStoryboard.init(name: StoryboardName.main, bundle: nil)
        if actionType == "solicitation"{
            if let vc = sb.instantiateViewController(withIdentifier: "ActionPasseOneDemand") as? ActionPasseOneDemand {
                vc.setContent(content: title)
                vc.setActionId(actionId: actionId)
                vc.setActionType(actionType: actionType)
                if let currentVc = AppState.getTopViewController() as? HomeMainViewController{
                    currentVc.present(vc, animated: true)
                }
            }
        }
        if actionType == "contribution"{
            if let vc = sb.instantiateViewController(withIdentifier: "ActionPassedOneContrib") as? ActionPassedOneContrib {
                vc.setContent(content: title)
                vc.setActionId(actionId: actionId)
                vc.setActionType(actionType: actionType)
                if let currentVc = AppState.getTopViewController() as? HomeMainViewController{
                    currentVc.present(vc, animated: true)
                }
            }
        }
    }
}

//MARK: CLICK ON CELLS FUNCTIONS
extension HomeV2ViewController {
    func showAction(actionId:Int, isContrib:Bool, isAfterCreation:Bool = false, action:Action? = nil) {
        DeepLinkManager.showAction(id: actionId, isContrib: isContrib)
    }
    
    func showPedagogic(pedagogic:PedagogicResource){
        if let vc = storyboard?.instantiateViewController(withIdentifier: "pedagoDetailVC") as? PedagogicDetailViewController {
            vc.urlWebview = pedagogic.url
            vc.resourceId = pedagogic.id
            vc.isRead = pedagogic.isRead
            vc.htmlBody = pedagogic.bodyHtml
            AnalyticsLoggerManager.logEvent(name: Pedago_View_card)
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
    func showUserProfile(id:Int) {
        DeepLinkManager.showUser(userId: id)
    }
    
    func showEvent(eventId:Int, isAfterCreation:Bool = false, event:Event? = nil) {
        if let navVc = UIStoryboard.init(name: StoryboardName.event, bundle: nil).instantiateViewController(withIdentifier: "eventDetailNav") as? UINavigationController, let vc = navVc.topViewController as? EventDetailFeedViewController  {
            vc.eventId = eventId
            vc.event = event
            vc.isAfterCreation = isAfterCreation
            vc.modalPresentationStyle = .fullScreen
            self.tabBarController?.present(navVc, animated: true, completion: nil)
            return
        }
    }
    
    func showNeighborhood(neighborhoodId:Int, isAfterCreation:Bool = false, isShowCreatePost:Bool = false, neighborhood:Neighborhood? = nil) {
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
            // Si le cookie n'existe pas, on crée un cookie avec la valeur true
            defaults.set(true, forKey: "isTranslatedByDefault")
        }
    }

    
    func showResources() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "listPedagoNav") {
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func showNeighborhoodDetailWithCreatePost(id:Int,group:Neighborhood) {
        DeepLinkManager.showNeighborhoodDetailWithCreatePost(id: id, group:group)
    }
    
    func showAllNeighborhoods() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNeighborhoodShowDiscover), object: nil)
    }
    
    
}

extension HomeV2ViewController:HomeEventHCCDelegate{
    func goToMyEventHomeCell(event: Event) {
        showEvent(eventId: event.uid)
    }
    
    
}
extension HomeV2ViewController:HomeGroupCCDelegate{
    func goToMyGroup(group: Neighborhood) {
        showNeighborhood(neighborhoodId: group.uid)
    }
    
}


//MARK: OTHER DELEGATES

extension HomeV2ViewController:SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        
    }
}

extension HomeV2ViewController:WelcomeOneDelegate{
    func onClickedLink() {
        AnalyticsLoggerManager.logEvent(name: Action_WelcomeOfferHelp_Day1)
        showResources()
    }
    
    
}

extension HomeV2ViewController:WelcomeTwoDelegate {
    func goMyGroup(id: Int, group: Neighborhood) {
        showNeighborhoodDetailWithCreatePost(id: id,group:group)
        
    }
    func goGroupList() {
        self.showAllNeighborhoods()
    }
}

extension HomeV2ViewController:WelcomeThreeDelegate{
    
}

extension HomeV2ViewController:MJAlertControllerDelegate{
    func validateLeftButton(alertTag: MJAlertTAG) {
        //Here launch two ActionPassedTwoVC
        let actionType = self.userHome.unclosedAction?.actionType
        let actionId = self.userHome.unclosedAction?.id
        
        DispatchQueue.main.async {
            let sb = UIStoryboard.init(name: StoryboardName.main, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "ActionPassedTwoVC") as? ActionPassedTwoVC {
                if actionId != nil {
                    vc.setActionId(id: actionId!)
                    
                }
                if let currentVc = AppState.getTopViewController() as? HomeMainViewController{
                    currentVc.present(vc, animated: true)
                }
            }
        }
    }
    
    func validateRightButton(alertTag: MJAlertTAG) {
        //Here launch one ActionPassedOneVC
        let actionType = self.userHome.unclosedAction?.actionType!
        let actionId = self.userHome.unclosedAction?.id
        DispatchQueue.main.async {
            let sb = UIStoryboard.init(name: StoryboardName.main, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "ActionPassedOneVC") as? ActionPassedOneVC {
                if actionId != nil {
                    vc.setActionId(id: actionId!)
                }
                if actionType != nil {
                    vc.setActionType(actionType: actionType!)
                }
                
                if let currentVc = AppState.getTopViewController() as? HomeMainViewController{
                    currentVc.present(vc, animated: true)
                }
            }
        }
    }
}

//MARK: SCROLLVIEW ANIMATION

extension HomeV2ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 { // Si le défilement est supérieur à 0
            // Mettre à jour la contrainte et cacher le label
            if ui_drivable_top_constraint.constant != 5 {
                UIView.animate(withDuration: 0.3) {
                    self.ui_drivable_top_constraint.constant = 5
                    self.ui_drivable_table_view_top_constraint.constant = 15
                    self.ui_label_subtitle.alpha = 0
                    self.view.layoutIfNeeded() // Force la mise à jour de la vue pour refléter le changement de contrainte
                }
            }
        } else { // Si le défilement est à 0 ou en dessous
            // Rétablir la contrainte et afficher le label
            if ui_drivable_top_constraint.constant != 20 {
                UIView.animate(withDuration: 0.3) {
                    self.ui_drivable_top_constraint.constant = 20
                    self.ui_drivable_table_view_top_constraint.constant = 40
                    self.ui_label_subtitle.alpha = 1
                    self.view.layoutIfNeeded() // Force la mise à jour de la vue pour refléter le changement de contrainte
                }
            }
        }
    }
}

extension HomeV2ViewController: HomeHZCellDelegate {
    func onCLickGoBuffet() {
        let urlStr = "https://reseauentourage.notion.site/Buffet-du-lien-social-69c20e089dbd483cb093e90ae2953a54"
        var webUrl:URL?
        webUrl = URL(string: urlStr)
        WebLinkManager.openUrlInApp(url: webUrl, presenterViewController: self)
    }
}



class AppManager {
    static let shared = AppManager()

    var isContributionPreference: Bool = false

    private init() {} // Ceci assure que AppManager ne peut être instancié qu'en utilisant `shared`
}

extension HomeV2ViewController: PlaceViewControllerDelegate {
    func modifyPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        if let gplace = googlePlace, let placeId = gplace.placeID {
            UserService.updateUserAddressWith(placeId: placeId, isSecondaryAddress: false) { error in
                if error?.error == nil {
                    //Clean pour afficher l'adresse retournée depuis le WS on garde ?
                }
            }
        }
    }
}
extension HomeV2ViewController:SimpleAlertClick{
    func onClickMainButton() {
        let sb = UIStoryboard(name: "ProfileParams", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "place_choose_vc") as? ParamsChoosePlaceViewController {
            vc.placeVCDelegate = self
            self.navigationController?.present(vc, animated: true)
        }
    }
}

extension HomeV2ViewController:Phase3fromAppDelegate{
    func sendOnboardingEnd() {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        // Instancier le OnboardingStartViewController à partir de la storyboard
        if let onboardingVC = storyboard.instantiateViewController(withIdentifier: "OnboardingEndViewController") as? OnboardingEndViewController {
            self.present(onboardingVC, animated: true, completion: nil)
        }
    }
    
    func updatePreference(userType: UserType) {
        var _user = currentUser
        _user?.goal = userType.getGoalString()
        UserService.updateUser(user: _user) { [weak self] user, error in
            IHProgressHUD.dismiss()
            if let user = user {
                self?.currentUser = user
            }
        }
    }
    
    func updateLoc(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        if let _place = googlePlace, let placeId = _place.placeID{
            UserService.updateUserAddressWith(placeId: placeId, isSecondaryAddress: false) { [weak self] error in
                IHProgressHUD.dismiss()
                
            }
        }
    }
}
