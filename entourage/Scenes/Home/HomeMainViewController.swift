//
//  HomeMainViewController.swift
//  entourage
//
//  Created by Jerome on 07/06/2022.
//

import UIKit

class HomeMainViewController: UIViewController {
    
    
    @IBOutlet weak var ui_notif_count: UILabel!
    @IBOutlet weak var ui_view_notif_nb: UIView!
    @IBOutlet weak var ui_view_notif: UIView!
    @IBOutlet weak var ui_username: UILabel!
    @IBOutlet weak var ui_view_user: UIView!
    @IBOutlet weak var ui_iv_user: UIImageView!
    @IBOutlet weak var ui_tableview: UITableView!
    
    var homeViewModel:HomeViewModel!
    
    let section_agir = 0
    let section_contribs = 1
    let section_help = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeViewModel = HomeViewModel(delegate: self)
        
        setupViews()
        updateTopView()
        getHomeUser()
        
        ui_tableview.delegate = self
        ui_tableview.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getHomeUser()
    }
    
    func setupViews() {
        ui_username.setupFontAndColor(style: ApplicationTheme.getFontH2Noir())
        ui_notif_count.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoBold(size: 12), color: .white))
        ui_view_notif_nb.layer.cornerRadius = ui_view_notif_nb.frame.height / 2
        ui_view_notif.layer.cornerRadius = ui_view_notif.frame.height / 2
        ui_iv_user.layer.cornerRadius = ui_iv_user.frame.height / 2
        
        ui_view_user.layer.cornerRadius = ui_view_user.frame.height / 2
        ui_view_user.layer.borderWidth = 0
        
        ui_view_user.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        ui_view_user.layer.shadowOpacity = 1
        ui_view_user.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        ui_view_user.layer.shadowRadius = 2
        
        ui_view_user.layer.rasterizationScale = UIScreen.main.scale
        ui_view_user.layer.shouldRasterize = true
        
        ui_tableview.register(UINib(nibName: HomeContribCell.identifier, bundle: nil), forCellReuseIdentifier: HomeContribCell.identifier)
        ui_tableview.register(UINib(nibName: HomeActionCell.identifier, bundle: nil), forCellReuseIdentifier: HomeActionCell.identifier)
        ui_tableview.register(UINib(nibName: HomeSectionCell.identifier, bundle: nil), forCellReuseIdentifier: HomeSectionCell.identifier)
        ui_tableview.register(UINib(nibName: HomeActionTeachCell.identifier, bundle: nil), forCellReuseIdentifier: HomeActionTeachCell.identifier)
        ui_tableview.register(UINib(nibName: HomeHelpCell.identifier, bundle: nil), forCellReuseIdentifier: HomeHelpCell.identifier)
        
    }
    
    func getHomeUser() {
        homeViewModel.getHomeDetail { isOk in
            self.updateTopView()
            
            //TODO: get WS new infos
//            if self.homeViewModel.userHome.actions.count > 0 {
//                self.addTimerShowPop()
//            }
        }
    }
    
    private func addTimerShowPop() {
        let timer = Timer(fireAt: Date().addingTimeInterval(1), interval: 0, target: self, selector: #selector(self.showCongratPopup), userInfo: nil, repeats: false)
              
        RunLoop.current.add(timer, forMode: .common)
    }
        
    @objc private func showCongratPopup() {
        let homeVC = HomeCongratPopupViewController()
        homeVC.configureCongrat(actions: homeViewModel.userHome.actions, parentVC: self.tabBarController)
        homeVC.show()
    }
    
    func updateTopView() {
        ui_username.text = String.init(format: "home_title_welcome".localized, homeViewModel.userHome.displayName)
        
        if let _urlstr = homeViewModel.userHome.avatarURL,  let url = URL(string: _urlstr) {
            ui_iv_user.sd_setImage(with: url,placeholderImage: UIImage.init(named: "placeholder_user"))
        }
        else {
            ui_iv_user.image = UIImage.init(named: "placeholder_user")
        }
        
        ui_notif_count.text = "\(homeViewModel.notifCount)"
        ui_view_notif_nb.isHidden = homeViewModel.notifCount == 0
        
        ui_tableview.reloadData()
        
        //TODO: a supprimer lorsque l'on aura les valeurs des notifs
        ui_view_notif_nb.isHidden = true
        ui_view_notif.isHidden = true
    }
    
    @IBAction func action_show_notifs(_ sender: Any) {
        showWIP(parentVC: self)
    }
    
    @IBAction func action_show_profile(_ sender: Any) {
        let navVC = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil).instantiateViewController(withIdentifier: "mainNavProfile")
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
    }
}

//MARK: - tableview datasource/delegate -
extension HomeMainViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case section_contribs:
            return 1 + 1 //Header
        case section_agir:
            return homeViewModel.actions.count + 2 //Cell Mandatory
        case section_help:
            return 1 + 2 //Header
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            var title = ""
            switch indexPath.section {
            case section_contribs:
                title = "home_contrib_title".localized
            case section_agir:
                title = "home_actions_title".localized
            case section_help:
                title = "home_help_title".localized
            default:
                break
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeSectionCell.identifier, for: indexPath) as! HomeSectionCell
            
            cell.populateCell(title: title)
            return cell
        }
        
        if indexPath.section == section_contribs {
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeContribCell.identifier,for: indexPath) as! HomeContribCell
            
            cell.populateCell(userHome: self.homeViewModel.userHome, delegate: self)
            
            return cell
        }
        
        if indexPath.section == section_help {
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: HomeHelpCell.identifier, for: indexPath) as! HomeHelpCell
                
                cell.populateCell(name: self.homeViewModel.moderatorName, subtitle: "home_help_subtitle".localized, bottomMargin: 10)
                
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: HomeActionCell.identifier, for: indexPath) as! HomeActionCell
                
                cell.populateCell(title: "home_cell_map".localized,imageUrl: nil, imageIdentifier: "ic_home_sol", bottomMargin: 32)
                return cell
            }
        }
        
        if indexPath.row == homeViewModel.actions.count + 1 { //Action madatory resources
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeActionTeachCell.identifier, for: indexPath) as! HomeActionTeachCell
            
            cell.populateCell(title: "home_cell_pedago".localized)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeActionCell.identifier, for: indexPath) as! HomeActionCell
        let action = homeViewModel.actions[indexPath.row - 1]
        cell.populateCell(title: "\(action.name)", imageUrl: action.action_url,imageIdentifier: nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 || indexPath.section == section_contribs { return }
        
        if indexPath.section == section_help {
            if indexPath.row == 1 {
                showUserProfile(id: self.homeViewModel.moderatorId)
            }
            else {
                showAllPois()
            }
            return
        }
        
        if indexPath.section == section_agir && indexPath.row != homeViewModel.actions.count + 1 {
            let action = homeViewModel.actions[indexPath.row - 1]
            
            homeViewModel.getEventFromAction(action)
        }
        else {
            showResources()
        }
    }
}

//MARK: - HomeContribDelegate -
extension HomeMainViewController:HomeContribDelegate {
    func showEncounterInfo() {
        let popup = MJPopupViewController()
        popup.setupAlertInfos(parentVC: self.tabBarController, title: "home_info_encounter_pop_title".localized, subtitile: "home_info_encounter_pop_subtitle".localized, imageName: "img_pop_info_encouter")
        popup.show()
    }
    
    func showNeighborhoodTab() {
        if self.homeViewModel.userHome.neighborhoodParticipationsCount > 0 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNeighborhoodShowMy), object: nil)
        }
        else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNeighborhoodShowDiscover), object: nil)
        }
    }
    
    func showEventTab() {
        if self.homeViewModel.userHome.outingParticipationsCount > 0 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationEventShowMy), object: nil)
        }
        else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationEventShowDiscover), object: nil)
        }
    }
}

//MARK: - HomeMainViewsActionsDelegate -
extension HomeMainViewController: HomeMainViewsActionsDelegate {
    func showUserProfile(id:Int) {
        if let  navVC = UIStoryboard.init(name: StoryboardName.userDetail, bundle: nil).instantiateViewController(withIdentifier: "userProfileNavVC") as? UINavigationController {
            if let _homeVC = navVC.topViewController as? UserProfileDetailViewController {
                _homeVC.currentUserId = "\(id)"
                
                self.navigationController?.present(navVC, animated: true)
            }
        }
    }
    
    func editMyProfile() {
        let sb = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil)
        let navVC = sb.instantiateViewController(withIdentifier: "editProfileMainNav")
        self.navigationController?.present(navVC, animated: true)
    }
    
    func showNeighborhoodDetail(id:Int) {
        let sb = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil)
        if let nav = sb.instantiateViewController(withIdentifier: "neighborhoodDetailNav") as? UINavigationController, let vc = nav.topViewController as? NeighborhoodDetailViewController {
            vc.isAfterCreation = false
            vc.neighborhoodId = id
            vc.isShowCreatePost = false
            vc.neighborhood = nil
            self.navigationController?.present(nav, animated: true)
        }
    }
    
    func showAllNeighborhoods() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNeighborhoodShowDiscover), object: nil)
    }
    
    func createNeighborhood() {
        let navVC = UIStoryboard.init(name: StoryboardName.neighborhoodCreate, bundle: nil).instantiateViewController(withIdentifier: "groupCreateVCMain") as! NeighborhoodCreateMainViewController
        navVC.parentController = self.tabBarController
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
    }
    
    func showPoi(id:Int) {
        let navVc = UIStoryboard.init(name: StoryboardName.solidarity, bundle: nil).instantiateInitialViewController() as? UINavigationController
        
        if let _controller = navVc?.topViewController as? GuideDetailPoiViewController {
            var poi = MapPoi()
            poi.uuid = "\(id)"
            _controller.poi = poi
            
            self.present(navVc!, animated: true, completion: nil)
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
    
    func showWebview(url:String) {
        if let realUrl = URL(string: url) {
            SafariWebManager.launchUrlInApp(url: realUrl, viewController: self)
            return
        }
    }
    
    func showResources() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "listPedagoNav") {
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func showResource(id:Int) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "pedagoDetailVC") as? PedagogicDetailViewController {
            vc.resourceId = id
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func showConversation(uuid:String) {
        //TODO: show conversation
        self.showWIP(parentVC: self.tabBarController)
    }
    
    func showAskForHelpDetail(id:Int) {
        self.showAction(id: id, isContrib: false)
    }
    func showAllAskForHelp() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationActionShowSolicitation), object: nil)
    }
    func createAskForHelp() {
        self.createAction(isContrib: false)
    }
    
    func showContribution(id:Int) {
        self.showAction(id: id, isContrib: true)
    }
    func showAllContributions() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationActionShowContrib), object: nil)
    }
    func createContribution() {
        self.createAction(isContrib: true)
    }
    
    private func showAction(id:Int,isContrib:Bool) {
        let sb = UIStoryboard.init(name: StoryboardName.actions, bundle: nil)
        if let navvc = sb.instantiateViewController(withIdentifier: "actionDetailFullNav") as? UINavigationController, let vc = navvc.topViewController as? ActionDetailFullViewController {
            vc.actionId = id
            vc.action = nil
            vc.isContrib = isContrib
            self.tabBarController?.present(navvc, animated: true)
        }
    }
    
    private func createAction(isContrib:Bool) {
        let sb = UIStoryboard.init(name: StoryboardName.actionCreate, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "actionCreateVCMain") as? ActionCreateMainViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.isContrib = isContrib
            vc.parentController = self
            self.tabBarController?.present(vc, animated: true)
        }
    }
    
    func showAllOutings() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationEventShowDiscover), object: nil)
    }
    func showOuting(id:Int) {
        if let navVc = UIStoryboard.init(name: StoryboardName.event, bundle: nil).instantiateViewController(withIdentifier: "eventDetailNav") as? UINavigationController, let vc = navVc.topViewController as? EventDetailFeedViewController  {
            vc.eventId = id
            vc.event = nil
            vc.isAfterCreation = false
            vc.modalPresentationStyle = .fullScreen
            self.tabBarController?.present(navVc, animated: true, completion: nil)
            return
        }
    }
}
