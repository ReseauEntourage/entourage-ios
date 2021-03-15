//
//  OTHomeMainViewController.swift
//  entourage
//
//  Created by Jr on 09/03/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTHomeMainViewController: UIViewController {

    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_button_tour: UIButton!
    
    var arrayFeed = [HomeCard]()
    
    let refreshControl = UIRefreshControl()
    
    var isFirstLaunchCheckName = true
    let NUMBER_OF_LAUNCH_CHECK = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatTotalUnreadCountBadge), name: NSNotification.Name.updateTotalUnreadCount, object: nil)
        
        let currentUser = UserDefaults.standard.currentUser
        
        if currentUser?.isPro() ?? false {
            ui_button_tour?.isHidden = false
            ui_button_tour?.layer.cornerRadius = 8
            ui_button_tour?.layer.borderWidth = 1
            ui_button_tour?.layer.borderColor = UIColor.appOrange()?.cgColor
        }
        else {
            ui_button_tour?.isHidden = true
        }
        
        refreshControl.addTarget(self, action: #selector(getFeed), for: .valueChanged)
        refreshControl.tintColor = UIColor.appOrange()

        if #available(iOS 10.0, *) {
            ui_tableview.refreshControl = refreshControl
        } else {
            ui_tableview.addSubview(refreshControl)
        }
        
        getFeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - Check profile + tuto
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.checkProfile()
        }
    }
    
    func checkProfile() {
        
        if isFirstLaunchCheckName {
            isFirstLaunchCheckName = false
            let currentUser = UserDefaults.standard.currentUser
            
            if currentUser?.firstName.count == 0 &&  currentUser?.lastName.count == 0 {
                let sb = UIStoryboard(name: "Onboarding_V2", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "Onboarding_inputNames")
                vc.modalPresentationStyle = .fullScreen
                self.tabBarController?.present(vc, animated: true, completion: nil)
                return
            }
        }
        let isAfterLogin = UserDefaults.standard.bool(forKey: "checkAfterLogin")
        let noMoreDemand = UserDefaults.standard.bool(forKey: "noMoreDemand")
        var numberOfLaunch = UserDefaults.standard.integer(forKey: "nbOfLaunch")
        
        numberOfLaunch = numberOfLaunch + 1
        UserDefaults.standard.setValue(numberOfLaunch, forKey: "nbOfLaunch")
        var hasToShow = false
        
        if !noMoreDemand {
            hasToShow = (numberOfLaunch > 0 && numberOfLaunch % NUMBER_OF_LAUNCH_CHECK == 0) ? true : false
        }
        
        if isAfterLogin || hasToShow {
            UserDefaults.standard.setValue(false, forKey: "checkAfterLogin")
            let currentUser = UserDefaults.standard.currentUser
            
            if currentUser?.goal == nil || currentUser?.goal?.count == 0 {
                let message = OTLocalisationService.getLocalizedValue(forKey: "login_info_pop_action")
                
                let alertVC = UIAlertController.init(title: OTLocalisationService.getLocalizedValue(forKey: "login_pop_information"), message: message, preferredStyle: .alert)
                
                let action = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey: "pop_info_entourage_custom_yes"), style: .default) { (action) in
                    let deepL = URL.init(string: "entourage://profileAction")
                    OTDeepLinkService.init().handleDeepLink(deepL)
                }
                
                let actionCancel = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey: "pop_info_entourage_custom_no"), style: .default, handler: nil)
                
                let actionNoMore = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey: "pop_info_entourage_custom_no_more"), style: .default) { (action) in
                    UserDefaults.standard.setValue(true, forKey: "noMoreDemand")
                }
                alertVC.addAction(actionNoMore)
                alertVC.addAction(actionCancel)
                alertVC.addAction(action)
                
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    
    @objc func getFeed() {
        var params = [String:Any]()
        if let currentLocation = OTLocationManager.sharedInstance()?.currentLocation {
            params["latitude"] = currentLocation.coordinate.latitude
            params["longitude"] = currentLocation.coordinate.longitude
        }
        
        OTNewFeedsService.getFeed(withParams:params) { (_array, error) in
            self.refreshControl.endRefreshing()
            if let _array = _array {
                self.arrayFeed.removeAll()
                self.arrayFeed.append(contentsOf: _array)
                self.ui_tableview.reloadData()
            }
            else {
                self.arrayFeed.removeAll()
                self.ui_tableview.reloadData()
                Logger.print("***** Return Error : \(String(describing: error?.localizedDescription))")
            }
        }
    }

    //MARK: - IBActions -
    @IBAction func action_show_tours(_ sender: Any?) {
        let sb = UIStoryboard.init(name: "Main2", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "OTFeedTourVC") as! OTFeedToursViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Methods Tours -
    func createTourFromNav() {
        if (presentedViewController?.isKind(of: OTMapOptionsViewController.self)) != nil {
            dismiss(animated: false) {
                self.action_show_tours(nil)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    if let vc = self.navigationController?.topViewController as? OTFeedToursViewController {
                        vc.createTourFromNav()
                    }
                }
            }
        }
    }
    
    func createEncounterFromNav() {
        self.action_show_tours(nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            if let vc = self.navigationController?.topViewController as? OTFeedToursViewController {
                vc.createQuickEncounter()
            }
        }
    }
    
    @objc func updatTotalUnreadCountBadge(notification: NSNotification) {
        if let _dict = notification.object as? NSDictionary, let totalUnreadCountBadge = _dict[kNotificationTotalUnreadCountKey] as? NSNumber {
            OTAppState.updateMessagesTabBadge(withValue: totalUnreadCountBadge.stringValue)
        }
    }
    
    //MARK: - Methods called from deeplink manager
    @objc func action_show_events() {
        self.showAllEvents()
     }
     
     @objc func action_show_feeds() {
        self.showAllActions()
     }
}

extension OTHomeMainViewController: UITableViewDelegate, UITableViewDataSource, CellClickDelegate {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayFeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if arrayFeed[indexPath.row].arrayCards.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellTitle", for: indexPath) as! OTHomeCellTitleView
            
            cell.populateCell(card: arrayFeed[indexPath.row],clickDelegate: self)
            
            return cell
        }
        
        var cell = OTHomeCellCollectionView()

        if arrayFeed[indexPath.row].type == .Headlines {
            cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCellAnnounces", for: indexPath) as! OTHomeCellCollectionView
        }
        else if arrayFeed[indexPath.row].type == .Events {
            cell = tableView.dequeueReusableCell(withIdentifier: "collectionCellEvents", for: indexPath) as! OTHomeCellCollectionView
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCellActions", for: indexPath) as! OTHomeCellCollectionView
        }
        
        cell.populateCell(card: arrayFeed[indexPath.row],clickDelegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if arrayFeed[indexPath.row].arrayCards.count == 0 {
            return UITableView.automaticDimension
        }
        if arrayFeed[indexPath.row].type == .Headlines {
            return 350
        }
        if arrayFeed[indexPath.row].type == .Events {
            return 300
        }
        return 318
    }
    
    //MARK: Delegate click Cells
    func showDetailUser(userId: NSNumber) {
        let navvc = UIStoryboard.init(name: "UserProfile", bundle: nil).instantiateInitialViewController()
        if let nav = navvc as? UINavigationController, let vc = nav.topViewController as? OTUserViewController {
            vc.userId = userId
            self.navigationController?.present(nav, animated: true, completion: nil)
        }
    }
    
    func selectCollectionViewCell(item:Any,type:HomeCardType) {
        if let _item = item as? OTEntourage {
            if _item.groupType == "outing" {
                let sb = UIStoryboard.init(name: "PublicFeedDetailNew", bundle: nil)
                let vc = sb.instantiateInitialViewController() as! OTDetailActionEventViewController
                vc.feedItem = _item
                self.navigationController?.pushViewController(vc, animated: true)
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            }
            else {
                let sb = UIStoryboard.init(name: "PublicFeedDetailNew", bundle: nil)
                let vc = sb.instantiateInitialViewController() as! OTDetailActionEventViewController
                
                vc.feedItem = _item
                self.navigationController?.pushViewController(vc, animated: true)
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            }
        }
        else if let _item = item as? OTAnnouncement {
            if let url = URL.init(string: _item.url) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func showDetail(type: HomeCardType) {
        switch type {
        case .Actions:
            showAllActions()
        case .Events:
            showAllEvents()
        default:
            break
        }
    }
    
    func showAllAnnounces() {
        let sb = UIStoryboard.init(name: "Main2", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "FeedNewsVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAllEvents() {
        let sb = UIStoryboard.init(name: "Main2", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "OTMain0")  as! OTFeedsViewController
        vc.isFromEvent = true
        vc.titleFrom = OTLocalisationService.getLocalizedValue(forKey: "outings_title_home")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAllActions() {
        let sb = UIStoryboard.init(name: "Main2", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "OTMain0") as! OTFeedsViewController
        vc.isFromEvent = false
        vc.titleFrom = OTLocalisationService.getLocalizedValue(forKey: "entourages_title_home")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
