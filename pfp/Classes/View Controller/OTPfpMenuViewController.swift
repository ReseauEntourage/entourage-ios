//
//  OTPfpMenuViewController.swift
//  pfp
//
//  Created by Veronica on 24/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import Foundation

final class OTPfpMenuViewController: UIViewController {
    var tableView = UITableView()
    var headerView = OTMenuHeaderView()
    private var menuItems = [OTMenuItem]()
    var currentUser = UserDefaults.standard.currentUser
    
    //MARK: - Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        OTAppConfiguration.configureNavigationControllerAppearance(self.navigationController)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - Private Functions
    
    private func setupUI() {
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.backgroundColor = UIColor.white
        tableView.separatorColor = .white
        customizeHeader()
        createMenuItems()
        tableView.register(OTItemTableViewCell.self, forCellReuseIdentifier: "ItemCellIdentifier")
        tableView.register(OTLogoutViewCell.self, forCellReuseIdentifier: "LogoutItemCellIdentifier")
    }
    
    private func customizeHeader() {
        headerView.editLabel.text = "Modifier mon profil"
        headerView.nameLabel.text = currentUser?.displayName
        headerView.profileBtn.setupAsProfilePicture(fromUrl: currentUser?.avatarURL, withPlaceholder: "user")
        headerView.profileBtn.addTarget(self, action: #selector(loadProfile), for: UIControlEvents.touchUpInside)
    }
    
    private func createMenuItems() {
        let contactItem = OTMenuItem(title: "Contacter l'équipe Voisin-Age", iconName:"question_chat")
        let howIsUsedItem = OTMenuItem(title: "Mode d'emploi de l'application", iconName: "howIsUsed")
        let ethicalChartItem = OTMenuItem(title: "Charte éthique de Voisin-Age", iconName: "ethicalChart")
        let aboutItem = OTMenuItem(title: String.localized("aboutTitle"), iconName:"contact")
        let donnationItem = OTMenuItem(title: String.localized("menu_donnation"), iconName:"star")
        let logoutItem = OTMenuItem(title: String.localized("menu_disconnect_title"), iconName: "")
        
        guard let item1 = contactItem,
            let item2 = howIsUsedItem,
            let item3 = ethicalChartItem,
            let item4 = aboutItem,
            let item5 = logoutItem,
            let item6 = donnationItem else {
            return
        }
        
        menuItems.append(item1)
        menuItems.append(item6)
        menuItems.append(item2)
        menuItems.append(item3)
        menuItems.append(item4)
        menuItems.append(item5)
    }
    
    private func loadAbout () {
        let vc = PFPAboutViewController.init(nibName: "PFPAboutView", bundle: nil)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func loadProfile () {
        let vc: OTUserViewController = UIStoryboard.userProfile().instantiateViewController(withIdentifier: "UserProfile") as! OTUserViewController
        vc.hidesBottomBarWhenPushed = true
        vc.userId = self.currentUser?.sid
        let profileNavController:UINavigationController = UINavigationController.init(rootViewController: vc)
        self.present(profileNavController, animated: true, completion: nil)
    }
}

extension OTPfpMenuViewController: UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView.editLabel.isHidden = true
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 51;
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: Refactor musai!!
        
        if indexPath.row == 0 {
            contactPFP()
        }
        else if indexPath.row == 1 {
            OTSafariService.launchFeedbackForm(in: self.navigationController)
        }
        else if indexPath.row == 2 {
            let url = URL(string: "http://bit.ly/charteethiquevoisin-age")
            OTSafariService.launchInAppBrowser(with: url, viewController: self.navigationController)
        }
        else if indexPath.row == 3 {
            let url = URL(string: "http://bit.ly/faqapplivoisin-age")
            OTSafariService.launchInAppBrowser(with: url, viewController: self.navigationController)
        }
        else if indexPath.row == 4 {
            self.loadAbout()
        }
        else {
            NotificationCenter.default.post(name: Notification.Name("loginFailureNotification"), object: self)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension OTPfpMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row != menuItems.count - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCellIdentifier") as! OTItemTableViewCell
            let icon:UIImage = UIImage(named: menuItems[indexPath.row].iconName)!
            cell.view.iconImageView.image = icon.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            cell.view.iconImageView.tintColor = UIColor.pfpBlue()
            cell.view.iconImageView.contentMode = UIViewContentMode.scaleAspectFit
            cell.view.itemLabel.text = menuItems[indexPath.row].title
            cell.backgroundColor = UIColor.pfpTableBackground()
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogoutItemCellIdentifier") as! OTLogoutViewCell
            cell.logoutButton.setTitle(menuItems[indexPath.row].title.uppercased(), for: .normal)
            return cell
        }
    }
}

extension OTPfpMenuViewController: MFMailComposeViewControllerDelegate {
    private func contactPFP() {
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: "", message: "email not available", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            return
        }
        
        let composeViewController = MFMailComposeViewController()
        composeViewController.mailComposeDelegate = self
        composeViewController.setToRecipients(["voisin-age@petitsfreresdespauvres.fr"])
        composeViewController.setSubject("")
        composeViewController.setMessageBody("", isHTML: false)
        present(composeViewController, animated: true, completion: nil)
    }
}
