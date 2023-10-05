//
//  HomeV2ViewController.swift
//  entourage
//
//  Created by Clement entourage on 20/09/2023.
//

import Foundation
import UIKit
import SafariServices


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
    case moderator(name:String, imageUrl:String)
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
    var pedagoCreateEvent:PedagogicResource?
    var pedagoCreateGroup:PedagogicResource?
    
    override func viewDidLoad() {
        prepareUINotifAndAvatar()
        ui_table_view.delegate = self
        ui_table_view.dataSource = self

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

    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentFilter.resetToDefault()
        self.initHome()
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
        AnalyticsLoggerManager.logEvent(name: Home_action_profile)
        let navVC = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil).instantiateViewController(withIdentifier: "mainNavProfile")
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
    }
    
    @objc func onNotifClick(){
        AnalyticsLoggerManager.logEvent(name: Home_action_notif)
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
            tableDTO.append(.cellTitle(title: "home_v2_title_action".localized, subtitle: "home_v2_subtitle_action".localized))
            for demand in allDemands {
                tableDTO.append(.cellAction(action: demand))
            }
            tableDTO.append(.cellSeeAll(seeAllType: .seeAllDemand))
        }
        if allEvents.count > 0 {
            tableDTO.append(.cellTitle(title: "home_v2_title_event".localized, subtitle: "home_v2_subtitle_event".localized))
            tableDTO.append(.cellEvent(events: allEvents))
            tableDTO.append(.cellSeeAll(seeAllType: .seeAllEvent))
        }
        if allGroups.count > 0 {
            tableDTO.append(.cellTitle(title: "home_v2_title_group".localized, subtitle: "home_v2_subtitle_group".localized))
            tableDTO.append(.cellGroup(groups: allGroups))
            tableDTO.append(.cellSeeAll(seeAllType: .seeAllGroup))
        }
        
        tableDTO.append(.cellTitle(title: "home_v2_title_map".localized, subtitle: "home_v2_subtitle_map".localized))
        tableDTO.append(.cellMap)
        
        if allPedagos.count > 0 {
            tableDTO.append(.cellTitle(title: "home_v2_title_pedago".localized, subtitle: "home_v2_subtitle_pedago".localized))
            for pedago in allPedagos {
                tableDTO.append(.cellPedago(pedago: pedago))
            }
            tableDTO.append(.cellSeeAll(seeAllType: .seeAllPedago))
        }
        tableDTO.append(.cellTitle(title: "home_v2_title_help".localized, subtitle: "home_v2_subtitle_help".localized))
        tableDTO.append(.cellIAmLost(helpType: .createGroup))
        tableDTO.append(.cellIAmLost(helpType: .createEvent))
        if let _moderator = userHome.moderator{
            if let _name = _moderator.displayName, let _image = _moderator.imgUrl{
                tableDTO.append(.moderator(name: _name, imageUrl: _image))
            }
        }
        self.ui_table_view.reloadData()
    }
    func initHome(){
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
                cell.configure(type: seeAllType)
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
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableDTO[indexPath.row]{
        case .cellTitle(_,_):
            return
        case .cellAction(let action):
            self.showAction(actionId: action.id, isContrib: false, action: action)
        case .cellSeeAll(let seeAllType):
            switch seeAllType{
            case .seeAllDemand:
                DeepLinkManager.showOutingListUniversalLink()
            case .seeAllEvent:
                DeepLinkManager.showDemandListUniversalLink()
            case .seeAllGroup:
                DeepLinkManager.showNeiborhoodListUniversalLink()
            case .seeAllPedago:
                DeepLinkManager.showOutingListUniversalLink()
            }
        case .cellEvent(_):
            return
        case .cellGroup(_):
            return
        case .cellPedago(let pedago):
            showPedagogic(pedagogic: pedago)
        case .cellMap:
            self.showAllPois()
        case .cellIAmLost(let helpType):
            switch helpType{
            case .createEvent:
                showPedagogic(pedagogic: pedagoCreateEvent!)
            case .createGroup:
                showPedagogic(pedagogic: pedagoCreateGroup!)
            }
        case .moderator(let name, let imageUrl):
            if let _moderator = self.userHome.moderator{
                showUserProfile(id: _moderator.id!)
            }
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
            return 210
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
        }
    }
}


//MARK: Here all call to API
extension HomeV2ViewController{
    func getNotif(){
        HomeService.getNotificationsCount { count, error in
            self.notificationCount = count ?? 0
            self.getDemandes()
        }
    }
    func getDemandes(){
        ActionsService.getAllActions(isContrib: false, currentPage: 1, per: 3, filtersLocation: currentLocationFilter.getfiltersForWS(), filtersSections: currentSectionsFilter.getallSectionforWS()) { actions, error in
            if let actions = actions {
                self.allDemands.removeAll()
                self.allDemands.append(contentsOf: actions)
            }
            self.getMyGroups()
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
            if let events = events , events.count > 0 {
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
                for k in 0...2{
                    self.allPedagos.append(resources[k])
                }
                for pedago in resources{
                    if pedago.id == 32{
                        self.pedagoCreateEvent = pedago
                    }else if pedago.id == 33{
                        self.pedagoCreateGroup = pedago
                    }
                }
            }
            self.getHomeDetail()
        }
    }
    func getHomeDetail() {
        HomeService.getUserHome { [weak self] userHome, error in
            if let userHome = userHome {
                self?.userHome = userHome
                
            }
            self?.configureDTO()
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
    func goToMyEvent(event: Event) {
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
            if ui_drivable_top_constraint.constant != 10 {
                UIView.animate(withDuration: 0.3) {
                    self.ui_drivable_top_constraint.constant = 10
                    self.ui_drivable_table_view_top_constraint.constant = 15
                    self.ui_label_subtitle.alpha = 0
                    self.view.layoutIfNeeded() // Force la mise à jour de la vue pour refléter le changement de contrainte
                }
            }
        } else { // Si le défilement est à 0 ou en dessous
            // Rétablir la contrainte et afficher le label
            if ui_drivable_top_constraint.constant != 40 {
                UIView.animate(withDuration: 0.3) {
                    self.ui_drivable_top_constraint.constant = 40
                    self.ui_drivable_table_view_top_constraint.constant = 40
                    self.ui_label_subtitle.alpha = 1
                    self.view.layoutIfNeeded() // Force la mise à jour de la vue pour refléter le changement de contrainte
                }
            }
        }
    }
}

