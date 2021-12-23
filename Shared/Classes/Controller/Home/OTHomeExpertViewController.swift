//
//  OTHomeExpertViewController.swift
//  entourage
//
//  Created by Jr on 07/04/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit
import AVFoundation


class OTHomeExpertViewController: UIViewController {
    
    let CELL_HEADLINES_HEIGHT:CGFloat = 330
    let CELL_EVENTS_HEIGHT:CGFloat = 320
    let CELL_ACTIONS_HEIGHT:CGFloat = 286
    
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_button_tour: UIButton!
    @IBOutlet weak var ui_view_top: UIView!
    
    var arrayFeed = [HomeCard]()
    var arrayFeedEmpty = [HomeCard]()
    var isLoading = true
    
    let refreshControl = UIRefreshControl()
    
    var isFirstLaunchCheckName = true
    let NUMBER_OF_LAUNCH_CHECK = 4
    
    var isFromModifyZone = false
    
    var isFromProfile = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createEmptyArray()
        
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
        
        OTLogger.logEvent(View_Start_ExpertFeed)
        
        self.getFeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        self.ui_view_top.layer.shadowColor = UIColor.black.cgColor
        self.ui_view_top.layer.shadowOpacity = 0.5
        self.ui_view_top.layer.shadowRadius = 4.0
        self.ui_view_top.layer.masksToBounds = false
        
        let _rect = CGRect(x: 0, y: self.ui_view_top.bounds.size.height , width: self.view.frame.size.width, height: self.ui_view_top.layer.shadowRadius)
        let _shadowPath = UIBezierPath(rect: _rect).cgPath
        self.ui_view_top.layer.shadowPath = _shadowPath
        
        if isFromModifyZone {
            isFromModifyZone = false
            getFeed()
        }
        
        if self.isFromProfile {
            self.ui_tableview.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: true)
            isFromProfile = false
        }
    }
        
    
    func createEmptyArray() {
        let card = OTFeedItem()
        let cards = [card,card,card]
        
        var home1 = HomeCard()
        home1.type = .Headlines
        home1.titleSection = "xxxxxxxxxxxx xxx"
        home1.arrayCards = [Any]()
        home1.arrayCards.append(contentsOf: cards)
        
        var home2 = HomeCard()
        home2.type = .Events
        home2.titleSection = "xxxxxxxxxxxx xxx"
        home2.arrayCards = [Any]()
        home2.arrayCards.append(contentsOf: cards)
        
        var home3 = HomeCard()
        home3.type = .Actions
        home3.titleSection = "xxxxxxxxxxxx xxx"
        home3.arrayCards = [Any]()
        home3.arrayCards.append(contentsOf: cards)
        
        arrayFeedEmpty.append(home1)
        arrayFeedEmpty.append(home2)
        arrayFeedEmpty.append(home3)
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
        //TODO: a remettre lorsque le back sera ok pour choisir les bonnes infos GPS à prendre
        //        if let currentLocation = OTLocationManager.sharedInstance()?.currentLocation {
        //            params["latitude"] = currentLocation.coordinate.latitude
        //            params["longitude"] = currentLocation.coordinate.longitude
        //        }
        
        if let currentLocation = UserDefaults.standard.currentUser.addressPrimary?.location {
            params["latitude"] = currentLocation.coordinate.latitude
            params["longitude"] = currentLocation.coordinate.longitude
        }
        isLoading = true
        OTNewFeedsService.getFeed(withParams:params) { (_array, error) in
            self.refreshControl.endRefreshing()
            self.isLoading = false
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
        OTLogger.logEvent(Action_expertFeed_Tour)
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
}

//MARK: - UITableViewDelegate/Datasource -
extension OTHomeExpertViewController: UITableViewDelegate, UITableViewDataSource, CellClickDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return arrayFeedEmpty.count
        }
        
        return arrayFeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isLoading {
            var cell = OTHomeCellCollectionView()
            
            if arrayFeedEmpty.count <= indexPath.row {
                return cell
            }
            
            if arrayFeedEmpty[indexPath.row].type == .Headlines {
                cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCellAnnouncesEmpty", for: indexPath) as! OTHomeCellCollectionView
            }
            else if arrayFeedEmpty[indexPath.row].type == .Events {
                cell = tableView.dequeueReusableCell(withIdentifier: "collectionCellEventsEmptyA", for: indexPath) as! OTHomeCellCollectionView
            }
            else {
                cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCellActionsEmptyA", for: indexPath) as! OTHomeCellCollectionView
            }
            
            cell.populateCell(card: arrayFeedEmpty[indexPath.row],clickDelegate: self, isLoading: isLoading)
            return cell
        }
        
        var cell = OTHomeCellCollectionView()
        
        if arrayFeed[indexPath.row].type == .Headlines {
            cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCellAnnounces", for: indexPath) as! OTHomeCellCollectionView
        }
        else if arrayFeed[indexPath.row].type == .Events {
            cell = tableView.dequeueReusableCell(withIdentifier: "collectionCellEventsA", for: indexPath) as! OTHomeCellCollectionView
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCellActionsA", for: indexPath) as! OTHomeCellCollectionView
        }
        
        cell.populateCell(card: arrayFeed[indexPath.row],clickDelegate: self, isLoading: isLoading)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if isLoading {
            if arrayFeedEmpty[indexPath.row].type == .Headlines {
                return CELL_HEADLINES_HEIGHT
            }
            if arrayFeedEmpty[indexPath.row].type == .Events {
                return CELL_EVENTS_HEIGHT
            }
            return CELL_ACTIONS_HEIGHT
        }
        
        if arrayFeed[indexPath.row].type == .Headlines {
            return CELL_HEADLINES_HEIGHT
        }
        if arrayFeed[indexPath.row].type == .Events {
            return CELL_EVENTS_HEIGHT
        }
        return CELL_ACTIONS_HEIGHT
    }
    
    //MARK: Delegate click Cells
    func showDetailUser(userId: NSNumber) {
        let navvc = UIStoryboard.init(name: "UserProfile", bundle: nil).instantiateInitialViewController()
        if let nav = navvc as? UINavigationController, let vc = nav.topViewController as? OTUserViewController {
            vc.userId = userId
            self.navigationController?.present(nav, animated: true, completion: nil)
        }
    }
    
    func selectCollectionViewCell(item:Any,type:HomeCardType, position:Int) {
        let posStr = "\(position+1)"
        var logString = ""

        if let _item = item as? OTEntourage {
            if _item.groupType == "outing" {
                if type == .Headlines {
                    logString = "\(Action_expertFeed_News_Event)\(posStr)"
                }
                else {
                    logString = "\(Action_expertFeed_Event)\(posStr)"
                }
                let sb = UIStoryboard.init(name: "PublicFeedDetailNew", bundle: nil)
                let vc = sb.instantiateInitialViewController() as! OTDetailActionEventViewController
                vc.feedItem = _item
                self.navigationController?.pushViewController(vc, animated: true)
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            }
            else {
                if type == .Headlines {
                    logString = "\(Action_expertFeed_News_Action)\(posStr)"
                }
                else {
                    logString = "\(Action_expertFeed_Action)\(posStr)"
                }
                let sb = UIStoryboard.init(name: "PublicFeedDetailNew", bundle: nil)
                let vc = sb.instantiateInitialViewController() as! OTDetailActionEventViewController
                
                vc.feedItem = _item
                self.parent?.navigationController?.pushViewController(vc, animated: true)
                self.parent?.navigationController?.setNavigationBarHidden(false, animated: true)
            }
        }
        else if let _item = item as? OTAnnouncement {
            logString = "\(Action_expertFeed_News_Announce)\(posStr)"
            if let url = URL.init(string: _item.url) {
                UIApplication.shared.openURL(url)
            }
        }
        OTLogger.logEvent(logString)
    }
    
    func showDetail(type: HomeCardType,isFromArrow:Bool,subtype:HomeCardType) {
        var logString = ""
        switch type {
        case .Actions:
            if isFromArrow {
                logString = Action_expertFeed_MoreActionArrow
            }
            else {
                logString = Action_expertFeed_MoreAction
            }
            showAllActions(subtype:subtype)
        case .Events:
            if isFromArrow {
                logString = Action_expertFeed_MoreEventArrow
            }
            else {
                logString = Action_expertFeed_MoreEvent
            }
            showAllEvents()
        default:
            break
        }
        
        OTLogger.logEvent(logString)
    }
    
    func showAllAnnounces() {
        let sb = UIStoryboard.init(name: "Main2", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "FeedNewsVC")
        self.parent?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAllEvents() {
        let sb = UIStoryboard.init(name: "Main2", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "OTMain0")  as! OTFeedsViewController
        vc.isFromEvent = true
        vc.titleFrom = OTLocalisationService.getLocalizedValue(forKey: "outings_title_home")
        OTLogger.logEvent(View_FeedView_Events)
        self.parent?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAllActions(subtype:HomeCardType) {
        let sb = UIStoryboard.init(name: "Main2", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "OTMain0") as! OTFeedsViewController
        vc.isFromEvent = false
        vc.titleFrom = OTLocalisationService.getLocalizedValue(forKey: "entourages_title_home")
       
        if subtype == .ActionsAsk || subtype == .ActionsContrib {
            let strTitle = subtype == .ActionsAsk ? "entourage_ask_for_helps_title_home" : "entourage_contributions_title_home"
            vc.titleFrom = OTLocalisationService.getLocalizedValue(forKey: strTitle)
            vc.isExpertArrowAsk = subtype == .ActionsAsk ? true : false
            vc.isExpertArrowContrib = subtype == .ActionsContrib ? true : false
            
            let tag = subtype == .ActionsAsk ? View_FeedView_Asks : View_FeedView_Contribs
            OTLogger.logEvent(tag)
        }
        
        self.parent?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showModifyZone() {
        OTLogger.logEvent(Event_expertFeed_ModifyActionZone)
        let storyB = UIStoryboard.init(name: "Onboarding_V2", bundle: nil)
        let vc = storyB.instantiateViewController(withIdentifier: "Onboarding_place") as! OTOnboardingPlaceViewController
        vc.isFromProfile = true
        vc.isSecondaryAddress = false
        self.isFromModifyZone = true
        self.parent?.navigationController?.show(vc, sender: nil)
    }
    
    func showHelpDistance() {
        OTLogger.logEvent(Action_expertFeed_HelpDifferent)
        let storyB = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyB.instantiateViewController(withIdentifier: "HomeHelpVC")
        self.parent?.navigationController?.show(vc, sender: nil)
    }
}
