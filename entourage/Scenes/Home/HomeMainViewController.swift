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
        ui_view_user.layer.borderColor = UIColor.white.cgColor
        ui_view_user.layer.borderWidth = 1
        
        ui_view_user.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
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
        }
    }
    
    func updateTopView() {
        ui_username.text = String.init(format: "home_title_welcome".localized, homeViewModel.userHome.displayName)
        
        if let url = URL(string: homeViewModel.userHome.avatarURL) {
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
        let navVC = UIStoryboard.init(name: "ProfileParams", bundle: nil).instantiateViewController(withIdentifier: "mainNavProfile")
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
        if section == 0 {
            return 1 + 1 //Header
        }
        
        if section == 1 {
            return homeViewModel.actions.count + 2 //Cell Mandatory
        }
        
        return 1 + 1 //Header
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            var title = ""
            switch indexPath.section {
            case 0:
                title = "home_contrib_title".localized
            case 1:
                title = "home_actions_title".localized
            default:
                title = "home_help_title".localized
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeSectionCell.identifier, for: indexPath) as! HomeSectionCell
            
            cell.populateCell(title: title)
            return cell
        }
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeContribCell.identifier,for: indexPath) as! HomeContribCell
            
            cell.populateCell(userHome: self.homeViewModel.userHome)
            
            return cell
        }
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeHelpCell.identifier, for: indexPath) as! HomeHelpCell
            
            //TODO: add moderator username
            cell.populateCell(name: "C'est moi ;)", subtitle: "home_help_subtitle".localized)
            
            return cell
            
        }
        
        if indexPath.row == homeViewModel.actions.count + 1 { //Action madatory resources
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeActionTeachCell.identifier, for: indexPath) as! HomeActionTeachCell
            
            cell.populateCell(title: "home_cell_pedago".localized)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeActionCell.identifier, for: indexPath) as! HomeActionCell
        let action = homeViewModel.actions[indexPath.row - 1]
        cell.populateCell(title: "\(action.name)", imageUrl: action.action_url)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 || indexPath.section == 0 { return }
        
        if indexPath.section == 2 {
            //TODO: show moderator user
            self.showWIP(parentVC: self)
        }
        
        if indexPath.section == 1 && indexPath.row != homeViewModel.actions.count + 1 {
            let action = homeViewModel.actions[indexPath.row - 1]
            
            homeViewModel.getEventFromAction(action)
        }
        else {
            showResources()
        }
    }
}

//MARK: - HomeMainViewsActionsDelegate -
extension HomeMainViewController: HomeMainViewsActionsDelegate {
    func showUserProfile(id:Int) {
        if let  navVC = UIStoryboard.init(name: "UserDetail", bundle: nil).instantiateViewController(withIdentifier: "userProfileNavVC") as? UINavigationController {
            if let _homeVC = navVC.topViewController as? UserProfileDetailViewController {
                _homeVC.currentUserId = "\(id)"
                
                self.navigationController?.present(navVC, animated: true)
            }
        }
    }
    
    func editMyProfile() {
        let sb = UIStoryboard.init(name: "ProfileParams", bundle: nil)
        let navVC = sb.instantiateViewController(withIdentifier: "editProfileMainNav")
        self.navigationController?.present(navVC, animated: true)
    }
    
    func showNeighborhoodDetail(id:Int) {
        let sb = UIStoryboard.init(name: "Neighborhood", bundle: nil)
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
        let navVC = UIStoryboard.init(name: "Neighborhood_Create", bundle: nil).instantiateViewController(withIdentifier: "groupCreateVCMain") as! NeighborhoodCreateMainViewController
        navVC.parentController = self.tabBarController
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
    }
    
    func showPoi(id:Int) {
        let navVc = UIStoryboard.init(name: "GuideSolidarity", bundle: nil).instantiateInitialViewController() as? UINavigationController
        
        if let _controller = navVc?.topViewController as? GuideDetailPoiViewController {
            var poi = MapPoi()
            poi.uuid = "\(id)"
            _controller.poi = poi
            
            self.present(navVc!, animated: true, completion: nil)
        }
    }
    
    func showAllPois() {
        let sb = UIStoryboard.init(name: "GuideSolidarity", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "MainGuide") as? MainGuideViewController {
            vc.isFromDeeplink = true
            let navVc = UINavigationController()
            
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
        //TODO: show pedago
        self.showWIP(parentVC: self)
    }
    func showResource(id:Int) {
        //TODO: show pedago
        self.showWIP(parentVC: self)
    }
    
    func showConversation(uuid:String) {
        //TODO: show conversation
        self.showWIP(parentVC: self)
    }
    
    func showAskForHelpDetail(id:Int) {
        //TODO: show demande
        self.showWIP(parentVC: self)
    }
    func showAllAskForHelp() {
        //TODO: show demandes
        self.tabBarController?.selectedIndex = 1
    }
    func createAskForHelp() {
        //TODO: create demande
        self.showWIP(parentVC: self)
    }
    
    func showContribution(id:Int) {
        //TODO: show contribution
        self.showWIP(parentVC: self)
    }
    func showAllContributions() {
        //TODO: show contributions
        self.tabBarController?.selectedIndex = 1
    }
    func createContribution() {
        //TODO: create contribution
        self.showWIP(parentVC: self)
    }
    
    func showAllOutings() {
        //TODO: show events
        self.tabBarController?.selectedIndex = 4
    }
    func showOuting(id:Int) {
        //TODO: show event
        self.showWIP(parentVC: self)
    }
}
