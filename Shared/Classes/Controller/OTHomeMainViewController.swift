//
//  OTHomeMainViewController.swift
//  entourage
//
//  Created by Jr on 15/02/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTHomeMainViewController: UIViewController {

    @IBOutlet weak var ui_view_top: UIView!
    @IBOutlet weak var ui_title: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(updatTotalUnreadCountBadge), name: NSNotification.Name.updateTotalUnreadCount, object: nil)
        
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
    }
    
    //MARK: - Check profile + tuto
    var isFirstLaunchCheckName = true
    let NUMBER_OF_LAUNCH_CHECK = 4
    
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
      
    func showOldMain() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "OTMain0") {
        
        self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func createTourFromNav() {
        Logger.print("***** ici create tour *****")
        
        if (presentedViewController?.isKind(of: OTMapOptionsViewController.self)) != nil {
            dismiss(animated: false) {
                Logger.print("***** segue ")
                self.action_show_maraude(nil)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    if let vc = self.navigationController?.topViewController as? OTFeedToursViewController {
                        vc.createTourFromNav()
                    }
                }
//                let sb = UIStoryboard.init(name: "TourCreator", bundle: nil)
//                if let vc = sb.instantiateInitialViewController() as? OTTourCreatorViewController {
//                    vc.view.backgroundColor = UIColor.clear
//                    vc.modalPresentationStyle = .currentContext
//                    vc.tourCreatorDelegate = self
//                    self.navigationController?.present(vc, animated: true, completion: nil)
//                }
            }
        }
    }
    
    func createEncounterFromNav() {
        Logger.print("***** ici create encounter tour *****")
        self.action_show_maraude(nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            if let vc = self.navigationController?.topViewController as? OTFeedToursViewController {
                vc.createQuickEncounter()
            }
        }
        /*
         [self dismissViewControllerAnimated:NO completion:^{
            // [self switchToNewsfeed];
             [self.editEncounterBehavior doEdit:nil
                                        forTour:self.tourCreatorBehavior.tour.uid
                                    andLocation:self.encounterLocation];
         }];
         */
    }
    
    @IBAction func action_show_oldMain(_ sender: Any) {
        showOldMain()
    }
    
    @IBAction func action_show_feeds(_ sender: Any) {
        let sb = UIStoryboard.init(name: "Main2", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "OTMain0")  as! OTFeedsViewController
        vc.isFromEvent = true
        vc.titleFrom = "Events"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func action_show_actions(_ sender: Any) {
        let sb = UIStoryboard.init(name: "Main2", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "OTMain0") as! OTFeedsViewController
        vc.isFromEvent = false
        vc.titleFrom = "Actions"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func action_show_maraude(_ sender: Any?) {
        let sb = UIStoryboard.init(name: "Main2", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "OTFeedTourVC") as! OTFeedToursViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func action_show_maraude2(_ sender: Any) {
        let sb = UIStoryboard.init(name: "Main2", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "TourVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func action_show_announcements(_ sender: Any) {
        let sb = UIStoryboard.init(name: "Main2", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "FeedNewsVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    // New Functions
    @objc func updatTotalUnreadCountBadge(notification: NSNotification) {
        if let _dict = notification.object as? NSDictionary, let totalUnreadCountBadge = _dict[kNotificationTotalUnreadCountKey] as? NSNumber {
            OTAppState.updateMessagesTabBadge(withValue: totalUnreadCountBadge.stringValue)
        }
    }
}


extension OTHomeMainViewController: OTTourCreatorDelegate {
    func createTour(_ tourType: String!) {
        //TODO: a faire
        Logger.print("***** Create tour à faire")
    }
    
    
}
