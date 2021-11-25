//
//  OTDetailActionEventViewController.swift
//  entourage
//
//  Created by Jr on 02/11/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import SVProgressHUD

class OTDetailActionEventViewController: UIViewController {
    
    @IBOutlet weak var ui_constraint_bottomView_height: NSLayoutConstraint!
    
    @IBOutlet weak var ui_button_bottom: UIButton!
    @IBOutlet weak var ui_label_bottom: UILabel!
    @IBOutlet weak var ui_view_bottom: UIView!
    @IBOutlet weak var ui_tableview: UITableView!
    
    @IBOutlet weak var ui_view_top_private: UIView!
    @IBOutlet weak var ui_label_top_private: UILabel!
    @IBOutlet weak var ui_constraint_height_top_view_private: NSLayoutConstraint!
    
    @IBOutlet weak var ui_view_button_close: UIView!
    @IBOutlet weak var ui_button_close: UILabel!
    @IBOutlet weak var ui_constraint_view_button_close_height: NSLayoutConstraint!
    
    let private_view_height:CGFloat = 100
    
    @objc var feedItem = OTFeedItem()
    
    var joiner = OTJoinBehavior()
    var editBehavor = OTEditEntourageBehavior()
    
    var popShareVC:OTInviteSourceViewController? = nil
    
    var arrayUsers = [OTFeedItemJoiner]()
    var numberOfCells = 6
    
    var isFromSearch = false
    var popview:OTPopInfoCustom? = nil
    
    var isShowCloseButton = false
    
    //MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.editBehavor.owner = self
        
        setupViewBottom()
        updateButtonsBehavior()
        
        setupMoreButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateStatus), name: NSNotification.Name.init(kNotificationJoinRequestSent), object: nil)
        
        loadMembers()
        
        if feedItem.isOuting() {
            OTLogger.logEvent(View_FeedDetail_Event)
        }
        else {
            OTLogger.logEvent(View_FeedDetail_Action)
        }
        addButtonClose()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OTAppConfiguration.configureNavigationControllerAppearance(self.navigationController)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        loadActionEvent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        OTAppState.hideTabBar(true)
    }
    
    func addButtonClose() {
        let currentStateInfo = OTFeedItemFactory.create(for: self.feedItem).getStateInfo?()
        let currentState = currentStateInfo?.getState()
        
        if OTAppConfiguration.supportsClosingFeedAction(self.feedItem) && currentState == FeedItemStateOpen && ((feedItem as? OTTour) == nil)  {
            isShowCloseButton = true
        }
        else {
            isShowCloseButton = false
        }
        
        if !isShowCloseButton {
            ui_constraint_view_button_close_height.constant = 0
            ui_button_close.isHidden = true
        }
        else {
            ui_button_close.isHidden = false
            ui_constraint_view_button_close_height.constant = 50
        }
        
        if self.feedItem.isAction() {
            ui_button_close.text = OTLocalisationService.getLocalizedValue(forKey: "button_close_action")
        }
        else {
            ui_button_close.text = OTLocalisationService.getLocalizedValue(forKey: "button_close_event")
        }
    }
    
    func showClosepop() {
        let storyB = UIStoryboard.init(name: "FeedChangeOptions", bundle: nil)
        if let vc = storyB.instantiateViewController(withIdentifier: "ConfirmCloseVC") as? OTConfirmCloseViewController {
            vc.feedItem = self.feedItem;
            vc.closeDelegate = self;
            
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueChangeState" {
            let vc = segue.destination as! OTChangeStateViewController
            vc.feedItem = feedItem
            vc.delegate = self
            vc.shouldShowTabBarOnClose = false
            vc.editEntourageBehavior = self.editBehavor
        }
        
        if segue.identifier == "UserProfileSegue" {
            if let navContr = segue.destination as? UINavigationController, let user = UserDefaults.standard.currentUser, let userId = sender as? Int {
                navContr.modalPresentationStyle = .fullScreen
                let userVC = navContr.topViewController as! OTUserViewController
                if !user.isAnonymous() && userId == user.sid.intValue {
                    userVC.user = user
                }
                else {
                    userVC.userId = NSNumber(value: userId)
                }
            }
        }
        if self.editBehavor.prepare(segue) {
            return
        }
    }
    
    @objc func updateStatus(notif:Notification) {
        if let _notifInfo = notif.userInfo, let notifTxt = _notifInfo["status"] as? String {
            if notifTxt == JOIN_PENDING {
                self.feedItem.joinStatus = JOIN_PENDING
                updateButtonsBehavior()
                NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: kNotificationReloadData)))
            }
            else if notifTxt == JOIN_ACCEPTED {
                self.feedItem.joinStatus = JOIN_ACCEPTED
                updateButtonsBehavior()
                
                NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: kNotificationReloadData)))
                showDiscussionPage()
            }
        }
    }
    
    //MARK: - Setups -
    func loadMembers() {
        if let feedItemFact = OTFeedItemFactory.create(for: feedItem) , let messaging = feedItemFact.getMessaging?() {
            messaging.getFeedItemUsers(withStatus: JOIN_ACCEPTED) { (items) in
                if let _array = items as? [OTFeedItemJoiner] {
                    self.arrayUsers.removeAll()
                    self.arrayUsers.append(contentsOf: _array)
                    self.ui_tableview.reloadData()
                }
            }
        failure: { (error) in
            Logger.print("***** error get feed users : \(String(describing: error?.localizedDescription))")
        }
        }
    }
    
    func loadActionEvent() {
        OTEntourageService().getEntourageWithStringId(feedItem.uuid) { entourage in
            if let _ent = entourage {
                self.feedItem = _ent
            }
            self.addButtonClose()
            self.loadMembers()
        } failure: { error in }
    }
    
    func setupViewBottom() {
        if feedItem.joinStatus == JOIN_ACCEPTED || feedItem.status == FEEDITEM_STATUS_CLOSED {
            ui_constraint_bottomView_height.constant = 0
        }
        else {
            ui_view_bottom.layer.shadowColor = UIColor.black.cgColor
            ui_view_bottom.layer.shadowOpacity = 0.5
            ui_view_bottom.layer.shadowRadius = 4.0
            ui_view_bottom.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        }
        
    }
    
    func setupMoreButton() {
        let more = UIButton.init(type: .custom)
        more.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        let image = UIImage.init(named: "more")?.withRenderingMode(.alwaysTemplate)
        
        more.setImage(image, for: .normal)
        more.tintColor = ApplicationTheme.shared().secondaryNavigationBarTintColor
        more.addTarget(self, action: #selector(startChangeStatus), for: .touchUpInside)
        
        let infoButton = UIBarButtonItem.init(customView: more)
        self.navigationItem.rightBarButtonItem = infoButton
    }
    
    @objc func startChangeStatus() {
        OTLogger.logEvent(Show_Menu_Options)
        self.performSegue(withIdentifier: "SegueChangeState", sender: self)
    }
    
    func updateButtonsBehavior() {
        var title = ""
        switch feedItem.joinStatus {
        case JOIN_ACCEPTED:
            title = OTLocalisationService.getLocalizedValue(forKey: "join_active_other")
        case JOIN_PENDING:
            title = OTLocalisationService.getLocalizedValue(forKey: "join_pending")
        default:
            title = OTLocalisationService.getLocalizedValue(forKey: "join_entourage2_btn")
            if feedItem.isOuting() {
                title = OTLocalisationService.getLocalizedValue(forKey: "join_entourage_btn")
            }
        }
        
        ui_button_bottom.setTitle(title.uppercased(), for: .normal)
        
        setBottomLabelAndButton()
        
        if feedItem.joinStatus == JOIN_PENDING {
            ui_label_top_private.text = OTLocalisationService.getLocalizedValue(forKey: "info_label_private_view")
            ui_constraint_height_top_view_private.constant = private_view_height
            ui_view_top_private.isHidden = false
        }
        else {
            ui_constraint_height_top_view_private.constant = 0
            ui_view_top_private.isHidden = true
        }
    }
    
    func showDiscussionPage() {
        let vc = UIStoryboard.activeFeeds()?.instantiateViewController(withIdentifier: "OTActiveFeedItemViewController") as? OTActiveFeedItemViewController
        
        vc?.feedItem = self.feedItem
        if let vc = vc {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func setBottomLabelAndButton() {
        ui_label_bottom.textColor = ApplicationTheme.shared().backgroundThemeColor
        ui_button_bottom.backgroundColor = ApplicationTheme.shared().backgroundThemeColor
        
        ui_button_bottom.setTitleColor(.white, for: .normal)
        
        ui_label_bottom.text = OTAppAppearance.joinEntourageLabelTitle(for: feedItem)
        
        if (feedItem.isOuting()) {
            ui_label_bottom.text = OTLocalisationService.getLocalizedValue(forKey: "join_event_lbl")
        }
        else {
            ui_label_bottom.text = OTLocalisationService.getLocalizedValue(forKey: "join_entourage_lbl")
        }
        
        if feedItem.joinStatus == JOIN_PENDING {
            ui_label_bottom.isHidden = true
            ui_button_bottom.backgroundColor = UIColor.white
            ui_button_bottom.layer.borderWidth = 1
            ui_button_bottom.layer.borderColor = ApplicationTheme.shared().backgroundThemeColor.cgColor
            
            ui_button_bottom.setTitleColor(ApplicationTheme.shared().backgroundThemeColor, for: .normal)
        }
        else {
            ui_button_bottom.layer.borderWidth = 0
            ui_label_bottom.isHidden = false
        }
        
        if feedItem.status == FEEDITEM_STATUS_CLOSED {
            ui_view_bottom.isHidden = true
            ui_constraint_bottomView_height.constant = 0
        }
        else {
            if feedItem.joinStatus == JOIN_ACCEPTED {
                ui_view_bottom.isHidden = true
                ui_constraint_bottomView_height.constant = 0
            }
            else {
                ui_view_bottom.isHidden = false
                ui_constraint_bottomView_height.constant = 88
            }
        }
        
        ui_tableview.reloadData()
    }
    
    //MARK: - IBActions -
    @IBAction func action_button_bottom_join(_ sender: Any) {
        actionJoin()
    }
    
    @IBAction func action_show_faq(_ sender: Any) {
        OTLogger.logEvent(Action_FeedItemInfo_FAQ)
        let relativeUrl = String.init(format: API_URL_MENU_OPTIONS, FAQ_LINK_ID,UserDefaults.standard.currentUser.token)
        if let _BaseUrl = OTHTTPRequestManager.sharedInstance()?.baseURL?.absoluteString {
            let url = String.init(format: "%@%@",_BaseUrl ,relativeUrl)
            
            OTSafariService.launchInAppBrowser(withUrlString: url, viewController: self.navigationController)
        }
    }
    
    @IBAction func action_show_partner(_ sender: UIButton) {
        let id = sender.tag
        self.showPartner(assoId: id)
    }
    
    @IBAction func action_close_view_private(_ sender: Any) {
        ui_view_top_private.isHidden = true
        ui_constraint_height_top_view_private.constant = 0
    }
    
    @IBAction func action_show_close(_ sender: Any) {
        showClosepop()
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate -
extension OTDetailActionEventViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if feedItem.isOuting() {
            if feedItem.isEventOnline() {
                numberOfCells = 6
            }
            else {
                numberOfCells = 7
            }
            
            return numberOfCells + arrayUsers.count
        }
        else {
            numberOfCells = 6
            return numberOfCells + arrayUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if feedItem.isOuting() {
            switch indexPath.row {
            case 0:
                return getCell(indexPath: indexPath,identifier: "cellTopEvent")
            case 1:
                return getCell(indexPath: indexPath,identifier: "cellEventDate")
            case 2:
                return getCell(indexPath: indexPath,identifier: "cellLocation")
            case 3:
                return getCell(indexPath: indexPath,identifier: "cellCreator")
            case 4:
                return getCell(indexPath: indexPath,identifier: "cellDescriptionEvent")
            case 5:
                if feedItem.isEventOnline() {
                    return getCell(indexPath: indexPath,identifier: "cellSelector")
                }
                return getCell(indexPath: indexPath,identifier: "cellMap")
            case 6:
                if feedItem.isEventOnline() {
                    return getCell(indexPath: indexPath,identifier: "MemberCellWithRole")
                }
                return getCell(indexPath: indexPath,identifier: "cellSelector")
            default:
                return getCell(indexPath: indexPath,identifier: "MemberCellWithRole")
            }
        }
        else {
            switch indexPath.row {
            case 0:
                return getCell(indexPath: indexPath,identifier: "cellTop")
            case 1:
                return getCell(indexPath: indexPath, identifier: "cellLocation")
            case 2:
                return getCell(indexPath: indexPath, identifier: "cellCreator")
            case 3:
                return getCell(indexPath: indexPath, identifier: "cellDescription")
            case 4:
                return getCell(indexPath: indexPath, identifier: "cellMap")
            case 5:
                return getCell(indexPath: indexPath, identifier: "cellSelector")
            default:
                return getCell(indexPath: indexPath, identifier: "MemberCellWithRole")
            }
        }
    }
    
    func getCell(indexPath:IndexPath, identifier:String) -> UITableViewCell {
        switch identifier {
        case "cellTop", "cellTopEvent":
            let cell = ui_tableview.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! OTDetailActionEventTopCell
            cell.populate(feedItem: feedItem as! OTEntourage, delegate: self)
            return cell
        case "cellEventDate":
            let cell = ui_tableview.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! OTDetailActionEventDateCell
            cell.populate(feedItem: feedItem as! OTEntourage)
            return cell
        case "cellLocation":
            let cell = ui_tableview.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! OTDetailActionEventLocationCell
            cell.populate(feedItem: feedItem as! OTEntourage)
            return cell
        case "cellCreator":
            let cell = ui_tableview.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! OTDetailActionEventCreatorCell
            cell.populate(feedItem: feedItem,delegate: self)
            return cell
        case "cellDescription","cellDescriptionEvent":
            let cell = ui_tableview.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! OTDetailActionEventDescriptionCell
            cell.populate(feedItem: feedItem as! OTEntourage)
            return cell
        case "cellMap":
            let cell = ui_tableview.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! OTDetailActionEventMapCell
            cell.populate(feedItem: feedItem)
            return cell
        case "cellSelector":
            let cell = ui_tableview.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            return cell
        default:
            let user = self.arrayUsers[indexPath.row - numberOfCells]
            let cell = ui_tableview.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! OTMembersCell
            cell.configure(with: user)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > numberOfCells - 1 {
            let user = self.arrayUsers[indexPath.row - numberOfCells]
            self.performSegue(withIdentifier: "UserProfileSegue", sender: user.uID)
        }
    }
}

//MARK: - ActionCellCreatorDelegate -
extension OTDetailActionEventViewController: ActionCellCreatorDelegate {
    func actionshowPartner() {
        if let assoId = feedItem.author?.partner?.aid.intValue {
            self.showPartner(assoId: assoId)
        }
    }
    
    func actionShowUser() {
        self.performSegue(withIdentifier: "UserProfileSegue", sender: feedItem.author.uID)
    }
    
    func showPartner(assoId:Int) {
        let sb = UIStoryboard.init(name: "AssociationDetails", bundle: nil)
        
        let navVC = sb.instantiateInitialViewController() as! UINavigationController
        let vc = navVC.topViewController as! OTAssociationDetailViewController
        navVC.modalPresentationStyle = .fullScreen
        vc.associationId = assoId
        self.navigationController?.present(navVC, animated: true, completion: nil)
    }
}

//MARK: - ActionCellTopDelegate /  InviteSourceDelegate -
extension OTDetailActionEventViewController:ActionCellTopDelegate, InviteSourceDelegate {
    func inviteContacts(from viewController: UIViewController!) {/* Not used */}
    func inviteByPhone() {/* Not used */}
    
    func share() {
        let shareB = OTShareFeedItemBehavior()
        shareB.owner = self
        shareB.configure(with: feedItem)
        shareB.shareMember(nil)
        popShareVC?.dismiss(animated: true, completion: nil)
        shareB.owner = nil
    }
    
    func shareEntourage() {
        let sb = UIStoryboard.activeFeeds()
        let vc = sb?.instantiateViewController(withIdentifier: "OTShareListEntouragesVC") as! OTShareEntourageViewController
        vc.feedItem = feedItem
        
        if #available(iOS 13.0, *) {
            vc.isModalInPresentation = true
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func actionShare() {
        let sb = UIStoryboard.activeFeeds()
        popShareVC = sb?.instantiateViewController(withIdentifier: "OTShareNew") as? OTInviteSourceViewController
        popShareVC?.delegate = self
        popShareVC?.feedItem = feedItem
        if let _ = popShareVC {
            self.present(popShareVC!, animated: true, completion: nil)
        }
    }
    
    func actionJoin() {
        if feedItem.joinStatus == JOIN_PENDING {
            let alertvc = UIAlertController.init(title: "Attention", message: OTLocalisationService.getLocalizedValue(forKey: "confirm_cancel_demand"), preferredStyle: .alert)
            let action_cancel = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey: "cancel"), style: .cancel) { (action) in
                alertvc.dismiss(animated: true, completion: nil)
            }
            let action_validate = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey: "pop_validate_event_bt_validate"), style: .default) { (action) in
                alertvc.dismiss(animated: true, completion: nil)
                self.actionCancel()
            }
            
            alertvc.addAction(action_validate)
            alertvc.addAction(action_cancel)
            
            self.present(alertvc, animated: true, completion: nil)
        }
        else if let _feed = feedItem as? OTEntourage, !_feed.isPublicEntourage() {
            showPopInfo()
        }
        else {
            self.joiner.join(self.feedItem)
        }
    }
    
    func actionCancel() {
        OTLogger.logEvent("ExitEntourageConfirm")
        SVProgressHUD.show()
        OTAppState.hideTabBar(false)
        
        OTFeedItemFactory.create(for: feedItem)!.getStateTransition!().quit(success: {
            SVProgressHUD.dismiss()
            OTLogger.logEvent("CancelJoinRequest")
            self.cancelledJoinRequest()
        }, orFailure: { (error) in
            SVProgressHUD.showError(withStatus: OTLocalisationService.getLocalizedValue(forKey: "generic_error"))
        })
    }
    
    func showPopInfo() {
        var _message:String = OTLocalisationService.getLocalizedValue(forKey: "pop_info_follow_private_action_message")
        if feedItem.isOuting() {
            _message = OTLocalisationService.getLocalizedValue(forKey: "pop_info_follow_private_event_message")
        }
        let btnOk:String = OTLocalisationService.getLocalizedValue(forKey: "pop_info_follow_private_action_bt_ok")
        let btnNok:String = OTLocalisationService.getLocalizedValue(forKey: "pop_info_follow_private_action_bt_cancel")
        
        if let _tabVc = tabBarController as? OTMainTabbarViewController {
            _tabVc.showPopInfo(delegate: self, title: OTLocalisationService.getLocalizedValue(forKey: "pop_info_follow_private_action_title"), message: _message, buttonOkStr: btnOk, buttonCancelStr: btnNok)
        }
        else if let _navVc = self.navigationController {
            self.showPopInfo(vc:_navVc, title: OTLocalisationService.getLocalizedValue(forKey: "pop_info_follow_private_action_title"), message: _message, buttonOkStr:btnOk, buttonCancelStr: btnNok)
        }
    }
}

//MARK: - OTPopInfoDelegate -
extension OTDetailActionEventViewController: OTPopInfoDelegate {
    func showPopInfo(vc:UIViewController, title:String,message:String,buttonOkStr:String,buttonCancelStr:String) {
        popview = OTPopInfoCustom.init(frame: vc.view.frame,delegate: self,title: title,message: message,buttonOkStr: buttonOkStr,buttonCancelStr: buttonCancelStr)
        
        vc.view.addSubview(popview!)
        vc.view.bringSubviewToFront(popview!)
    }
    
    func closePop() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePopView"), object: nil)
        if let popview = popview {
            popview.removeFromSuperview()
            self.popview = nil
        }
    }
    func validatePop() {
        self.joiner.join(self.feedItem)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePopView"), object: nil)
        if let popview = popview {
            popview.removeFromSuperview()
            self.popview = nil
        }
    }
}

//MARK: - OTStatusChangedProtocol -
extension OTDetailActionEventViewController: OTStatusChangedProtocol {
    func joinFeedItem() {
        self.dismiss(animated: true) {
            self.joiner.join(self.feedItem)
        }
    }
    
    func stoppedFeedItem() {
        if !self.isFromSearch {
            OTAppState.popToRootCurrentTab()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            SVProgressHUD.showSuccess(withStatus: OTLocalisationService.getLocalizedValue(forKey: "stopped_item"))
            if self.isFromSearch {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func closedFeedItem(with reason: OTCloseReason) {
        OTAppState.popToRootCurrentTab()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let _ = self.feedItem as? OTEntourage {
                let userInfo = [kNotificationSendReasonKey:reason.rawValue,kNotificationFeedItemKey:self.feedItem] as [String : Any]
                if self.feedItem.isOuting() && reason == OTCloseReasonSuccesClose {
                    NotificationCenter.default.post(name:Notification.Name(rawValue: kNotificationSendCloseMail),object: nil,userInfo: userInfo)
                }
                else  if reason != OTCloseReasonSuccesClose {
                    NotificationCenter.default.post(name:Notification.Name(rawValue: kNotificationSendCloseMail),object: nil,userInfo: userInfo)
                }
            }
            if reason == OTCloseReasonHelpClose {
                return
            }
            SVProgressHUD.showSuccess(withStatus: OTAppAppearance.closeFeedItemConformationTitle(self.feedItem))
            NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: kNotificationReloadData)))
        }
    }
    
    func quitedFeedItem() {
        if !self.isFromSearch {
            OTAppState.popToRootCurrentTab()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            SVProgressHUD.showSuccess(withStatus: OTAppAppearance.quitFeedItemConformationTitle(self.feedItem))
            NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: kNotificationReloadData)))
            if self.isFromSearch {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func cancelledJoinRequest() {
        if !self.isFromSearch {
            OTAppState.popToRootCurrentTab()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            SVProgressHUD.showSuccess(withStatus: OTLocalisationService.getLocalizedValue(forKey: "cancelled_join_request"))
            NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: kNotificationReloadData)))
            if self.isFromSearch {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

//MARK: - OTConfirmCloseProtocol
extension OTDetailActionEventViewController: OTConfirmCloseProtocol {
    func feedItemClosed(with reason: OTCloseReason, andComment comment: String!) {
        
        OTLogger.logEvent("CloseEntourageConfirm")
        
        if reason == OTCloseReasonHelpClose {
            return
        }
        
        let outcome = reason == OTCloseReasonSuccesClose ? true : false
        SVProgressHUD.show()
        
        let stateTrans = OTFeedItemFactory.create(for: feedItem).getStateTransition?()
        
        stateTrans?.close(withOutcome: outcome, andComment: comment, success: { isTour in
            SVProgressHUD.dismiss()
            self.dismissOnClose(reason: reason)
        }, orFailure: { error in
            SVProgressHUD.showError(withStatus: OTLocalisationService.getLocalizedValue(forKey: "generic_error"))
        })
    }
    
    func dismissOnClose(reason:OTCloseReason) {
        OTAppState.popToRootCurrentTab()
        OTAppState.hideTabBar(false)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) { [weak self] in
            if let feedItem = self?.feedItem, ((feedItem as? OTTour) == nil) {
                let userInfo = [kNotificationSendReasonKey:reason,kNotificationFeedItemKey:feedItem] as [String : Any]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationSendCloseMail), object: nil,userInfo: userInfo)
                
                if reason == OTCloseReasonHelpClose {
                    return
                }
                
                let title = OTAppAppearance.closeFeedItemConformationTitle(feedItem)
                SVProgressHUD.showSuccess(withStatus:title)
                
                NotificationCenter.default.post(name: NSNotification.Name(kNotificationReloadData), object: nil)
            }
        }
    }
}
