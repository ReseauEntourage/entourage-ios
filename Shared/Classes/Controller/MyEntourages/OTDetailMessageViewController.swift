//
//  OTDetailMessageViewController.swift
//  entourage
//
//  Created by Jerome on 06/01/2022.
//  Copyright © 2022 Entourage. All rights reserved.
//

import UIKit
import SVProgressHUD
import IQKeyboardManager
import SDWebImage

class OTDetailMessageViewController: UIViewController {
    
    @IBOutlet weak var ui_view_report: UIView!
    @IBOutlet weak var ui_tableview: UITableView!
    
    @IBOutlet weak var ui_constraint_view_report_top: NSLayoutConstraint!
    @IBOutlet weak var ui_bt_sendMessage: UIButton!
    @IBOutlet weak var ui_tv_chat: OTAutoGrowTextView!
    
    var feedItem:OTFeedItem = OTFeedItem()
    var arrayItems = [OTFeedItemTimelinePoint]()
    var entourageInfo:OTEntourage?
    
    @IBOutlet weak var ui_constraint_bottom_textview: NSLayoutConstraint!
    let bottomConstraintTextview = 10
    
    //MARK: - LifeCycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_tableview.rowHeight = UITableView.automaticDimension
        ui_tableview.estimatedRowHeight = 100
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        
        updateUnread()
        updateViewReport()
        
        IQKeyboardManager.shared().isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(showProfile(notification:)), name: NSNotification.Name("showUserProfile"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        setupTopBar()
        self.getEntourageInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadMessages()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - notif keyboard -
    
    @objc func showKeyboard(notification:Notification) {
        let kbFrame = keyboardFrame(notification: notification)
        if let _height = kbFrame?.size.height {
            self.ui_constraint_bottom_textview.constant = CGFloat(self.bottomConstraintTextview) + _height
        }
    }
    
    @objc func hideKeyboard(notification:Notification) {
        self.ui_constraint_bottom_textview.constant = CGFloat(self.bottomConstraintTextview)
    }
    
    func keyboardFrame(notification:Notification) -> CGRect? {
        if let userInfo = notification.userInfo {
            return userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        }
        return nil
    }
    
    //MARK: - Update views -
    
    func setupTopBar() {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.setBackgroundImage(UIImage.init(named: "info_orange"), for: .normal)
        button.addTarget(self, action: #selector(showInfo), for: .touchUpInside)
        
        let infoButton = UIBarButtonItem(customView: button)
        self.navigationItem.setRightBarButton(infoButton, animated: true)
    }
    
    func addButtonsToNavBar(iconView:UIImageView) {
        var leftItems = [UIBarButtonItem]()
        
        let backImage = UIImage(named: "backItem")?.withRenderingMode(.alwaysTemplate)
        let backItem = UIBarButtonItem(image: backImage, style: .done, target: self, action: #selector(backButton))
        backItem.tintColor = ApplicationTheme.shared().secondaryNavigationBarTintColor
        let barItem = UIBarButtonItem(customView: iconView)
        
        leftItems.append(backItem)
        leftItems.append(barItem)
        self.navigationItem.leftBarButtonItems = leftItems
    }
    
    func setupTitleUser() {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        titleLabel.text = entourageInfo?.title
        titleLabel.textColor = ApplicationTheme.shared().secondaryNavigationBarTintColor
        titleLabel.numberOfLines = 1
        titleLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showInfo))
        titleLabel.addGestureRecognizer(tapGesture)
        self.navigationItem.titleView = titleLabel
        
        //Image
        let iconSize:CGFloat = 36
        let tapGestureIcon = UITapGestureRecognizer(target: self, action: #selector(showInfo))
        let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: iconSize, height: iconSize))
        iconView.backgroundColor = .white
        iconView.layer.cornerRadius = iconSize / 2
        iconView.isUserInteractionEnabled = true
        iconView.clipsToBounds = true
        iconView.contentMode = .scaleAspectFit
        iconView.addGestureRecognizer(tapGestureIcon)
        iconView.image = UIImage(named: "user")?.resize(to: iconView.frame.size)
        
        if let urlPath = entourageInfo?.author.avatarUrl, let url = URL(string: urlPath) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    self.addButtonsToNavBar(iconView: iconView)
                    return
                }
                
                DispatchQueue.main.async {
                    if let image = UIImage(data: data) {
                        iconView.image = image.resize(to: iconView.frame.size)
                    }
                    self.addButtonsToNavBar(iconView: iconView)
                }
            }
            task.resume()
        }
        else {
            self.addButtonsToNavBar(iconView: iconView)
        }
    }
    
    func validateReport() {
        self.feedItem.display_report_prompt = false
        self.updateViewReport()
    }
    
    func updateViewReport() {
        if (self.feedItem.isConversation() && self.feedItem.isDisplay_report_prompt()) {
            self.ui_constraint_view_report_top.constant = 0;
        }
        else {
            self.ui_constraint_view_report_top.constant = -self.ui_view_report.frame.size.height;
        }
    }
    
    //MARK: - Actions -
    
    @objc func backButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func showInfo() {
        if let _entourage = entourageInfo {
            showUserProfile(userId: _entourage.author.uID)
        }
    }
    
    @objc func showProfile(notification:Notification) {
        if let userUID = notification.userInfo?["userUID"] as? NSNumber {
            showUserProfile(userId: userUID)
        }
    }
    
    func showUserProfile(userId:NSNumber) {
        let sb = UIStoryboard.userProfile()
        if let navVc = sb?.instantiateInitialViewController() as? UINavigationController, let vc = navVc.topViewController as? OTUserViewController {
            let currentUser = UserDefaults.standard.currentUser
            if currentUser?.sid.intValue == userId.intValue {
                vc.user = currentUser
            }
            else {
                vc.userId = userId
            }
            self.present(navVc, animated: true, completion: nil)
        }
    }
    
    //MARK: - Network -
    
    func getEntourageInfo() {
        OTEntourageService().getEntourageWithStringId(feedItem.uuid) { entourage in
            self.entourageInfo = entourage
            self.setupTitleUser()
        } failure: { error in }
    }
    
    func reloadMessages() {
        arrayItems.removeAll()
        ui_tableview.reloadData()
        if let _entourage = feedItem as? OTEntourage, let messaging = OTEntourageMessaging(entourage: _entourage) {
            SVProgressHUD.show()
            messaging.getMessagesWithSuccess { items in
                SVProgressHUD.dismiss()
                if let _items = items as? [OTFeedItemTimelinePoint], _items.count > 0 {
                    self.insertDates(items: _items)
                    self.updateViewReport()
                }
            } failure: { error in SVProgressHUD.dismiss() }
        }
    }
    
    //order messages + insert headers dates
    func insertDates(items:[OTFeedItemTimelinePoint]) {
        let sortedItems = items.sorted { a, b in
            return a.date < b.date
        }
        
        var result = [OTFeedItemTimelinePoint]()
        var date = Date(timeIntervalSince1970: 0)
        
        for item in sortedItems {
            if !Calendar.current.isDate(item.date, inSameDayAs: date) {
                date = item.date
                let chatPoint = OTFeedItemTimelinePoint()
                chatPoint.date = date
                result.append(chatPoint)
            }
            result.append(item)
        }
        arrayItems.removeAll()
        arrayItems.append(contentsOf: result)
        DispatchQueue.main.async {
            self.ui_tableview.reloadData()
        }
    }
    
    func updateUnread() {
        Logger.print("***$* start update read")
        let _messageDelegate = OTFeedItemFactory.create(for: feedItem).getMessaging?()
        _messageDelegate?.setMessagesAsRead({ [weak self] in
            Logger.print("***$* end update read")
            if let self = self {
                OTUnreadMessagesService().setGroupAsRead(self.feedItem.uid, stringId: self.feedItem.uuid, refreshFeed: false)
            }
        }, orFailure: { error in })
    }
    
    //MARK: - IBActions -
    
    @IBAction func action_send_message(_ sender: Any) {
        let message = ui_tv_chat.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if message.count == 0 {
            return
        }
        
        SVProgressHUD.show()
        
        if let _entourage = feedItem as? OTEntourage, let messaging = OTEntourageMessaging(entourage: _entourage) {
            OTLogger.logEvent("AddContentToMessage")
            messaging.send(message) { responseMessage in
                SVProgressHUD.dismiss()
                self.ui_tv_chat.text = ""
                self.reloadMessages()
                OTAppState.checkNotifications(completionHandler: nil)
            } orFailure: { error in
                SVProgressHUD.showError(withStatus: OTLocalisationService.getLocalizedValue(forKey: "generic_error"))
            }
        }
    }
    
    @IBAction func action_close_report(_ sender: Any) {
        validateReport()
    }
    
    @IBAction func action_report(_ sender: Any) {
        let txtColor = UIColor.appOrange()
        let storyboard = UIStoryboard.init(name: "Popup", bundle: nil)
        
        let titleStr = "report_contribution_title".localized
        let descriptionStr = "report_contribution_attributed_title".localized
        
        let popupVC = storyboard.instantiateInitialViewController() as! OTPopupViewController
        
        let firstString = NSMutableAttributedString(string: titleStr)
        firstString.addAttribute(NSAttributedString.Key.foregroundColor, value: txtColor as Any, range: NSRange(location: 0, length: firstString.length))
        
        let attributedString = NSMutableAttributedString(string: descriptionStr)
        
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "SFUIText-Medium", size: 17) as Any, range: NSRange(location: 0, length: attributedString.length))
        
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: txtColor as Any, range: NSRange(location: 0, length: attributedString.length))
        
        firstString.append(attributedString)
        
        
        popupVC.labelString = firstString
        popupVC.textFieldPlaceholder = "report_entourage_placeholder".localized
        popupVC.buttonTitle = "report_entourage_button".localized
        popupVC.isEntourageReport = true
        popupVC.entourageId = (self.feedItem as! OTEntourage).uid.stringValue
        popupVC.detailMessagesVC = self
        
        self.present(popupVC, animated: true, completion: nil)
    }
    
    @IBAction func action_report_cancel(_ sender: Any) {
        OTEntourageService().deleteReportUserPrompt(forEntourage: self.feedItem.uuid) {
            self.validateReport()
        } failure: { error in }
    }
}

//MARK: - uitableview datasource / delegate -
extension OTDetailMessageViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Logger.print("***$* number of rows : \(arrayItems.count)")
        return arrayItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = arrayItems[indexPath.row]
        if let _item = item as? OTFeedItemMessage {
            let currentUser = UserDefaults.standard.currentUser
            let cellIdentifier = _item.uID == currentUser?.sid ? "MessageSentCell" : "MessageReceivedCell"
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! OTChatCellBase
            cell.configure(with: _item)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatDateCell", for: indexPath) as! OTChatCellBase
            cell.configure(with: item)
            return cell
        }
    }
}
