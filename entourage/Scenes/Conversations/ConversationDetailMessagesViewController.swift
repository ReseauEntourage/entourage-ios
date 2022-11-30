//
//  ConversationDetailMessagesViewController.swift
//  entourage
//
//  Created by Jerome on 23/08/2022.
//

import UIKit
import IQKeyboardManagerSwift
import IHProgressHUD

//Use to transform messages to section date with messages
struct MessagesSorted {
    var messages = [Any]()
    var datesSections = 0
}

class ConversationDetailMessagesViewController: UIViewController {
    
    @IBOutlet weak var ui_bt_title_user: UIButton!
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_view_txtview: UIView!
    
    @IBOutlet weak var ui_iv_bt_send: UIImageView!
    @IBOutlet weak var ui_view_button_send: UIView!
    @IBOutlet weak var ui_constraint_bottom_view_Tf: NSLayoutConstraint!
    @IBOutlet weak var ui_textview_message: MJTextViewPlaceholder!
    
    @IBOutlet weak var ui_view_empty: UIView!
    @IBOutlet weak var ui_title_empty: UILabel!
    
    @IBOutlet weak var ui_constraint_tableview_top_top: NSLayoutConstraint!
    @IBOutlet weak var ui_constraint_tableview_top_margin: NSLayoutConstraint!
    @IBOutlet weak var ui_view_new_conversation: UIView!
    @IBOutlet weak var ui_title_new_conv: UILabel!
    @IBOutlet weak var ui_subtitle_new_conv: UILabel!
    
    
    private var conversationId:Int = 0
    private var currentMessageTitle:String? = nil
    private var currentUserId:Int = 0
    private var hasToShowFirstMessage = false
    private var isOneToOne = true
    private var selectedIndexPath:IndexPath? = nil
    private weak var parentDelegate:UpdateUnreadCountDelegate? = nil
    
    
    @IBOutlet weak var ui_view_block: UIView!
    @IBOutlet weak var ui_title_block: UILabel!
    
    var messages = [PostMessage]()
    var messagesExtracted = MessagesSorted()
    var meId:Int = 0
    
    var messagesForRetry = [PostMessage]()
    
    let placeholderTxt = "messaging_message_placeholder_discut".localized
    
    var bottomConstraint:CGFloat = 0
    var isStartEditing = false
    
    
    
    var currentPage = 1
    let numberOfItemsForWS = 50 // Arbitrary nb of items used for pagging
    let nbOfItemsBeforePagingReload = 5 // Arbitrary nb of items from the top of the list to send new call
    var isLoading = false
    
    var paramVC:UIViewController? = nil
    
    var currentConversation:Conversation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = false
        
        ui_bt_title_user.isHidden = !isOneToOne
        
        let _title = currentMessageTitle ?? "messaging_message_title".localized
        
        ui_top_view.populateView(title: _title, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self,backgroundColor: .appBeigeClair, isClose: false,doubleRightMargin:true)
        
        ui_title_empty.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_title_empty.text = "messaging_message_no_message".localized
        ui_view_empty.isHidden = true
        
        ui_view_txtview.layer.borderWidth = 1
        ui_view_txtview.layer.borderColor = UIColor.appOrange.cgColor
        ui_view_txtview.layer.cornerRadius = ui_view_txtview.frame.height / 2
        
        ui_textview_message.delegate = self
        ui_textview_message.hasToCenterTextVerticaly = true
        
        ui_view_button_send.backgroundColor = .clear
        ui_iv_bt_send.image = UIImage.init(named: "ic_send_comment_off")
        
        
        ui_view_block.layer.borderWidth = 1
        ui_view_block.layer.borderColor = UIColor.appGris112.cgColor
        ui_view_block.layer.cornerRadius = ui_view_block.frame.height / 2
        ui_title_block.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 14,color: .appGris112))
        ui_view_block.isHidden = true
        
        let _width = UIApplication.shared.delegate?.window??.frame.width ?? view.frame.size.width
        let buttonDone = UIBarButtonItem(title: "messaging_message_send".localized, style: .plain, target: self, action: #selector(closeKb(_:)))
        ui_textview_message.addToolBar(width: _width, buttonValidate: buttonDone)
        ui_textview_message.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        ui_textview_message.placeholderText = placeholderTxt
        ui_textview_message.placeholderColor = .appOrange
        
        guard let me = UserDefaults.currentUser else {
            return goBack()
        }
        meId = me.sid
        
        getMessages()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        bottomConstraint = ui_constraint_bottom_view_Tf.constant
        
        ui_title_new_conv.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
        ui_subtitle_new_conv.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_title_new_conv.text = "message_title_new_conv".localized
        ui_subtitle_new_conv.text = "message_subtitle_new_conv".localized
        
        hideViewNew()
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeFromParams), name: NSNotification.Name(rawValue: kNotificationMessagesUpdate), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userBlockedFromParams), name: NSNotification.Name(rawValue: kNotificationMessagesUpdateUserBlocked), object: nil)

        self.getDetailConversation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isStartEditing {
            isStartEditing = false
            _ = ui_textview_message.becomeFirstResponder()
        }
    }
    
    //MARK: setup variables from other VC ;)
    func setupFromOtherVC(conversationId:Int,title:String?,isOneToOne:Bool,conversation:Conversation? = nil, delegate:UpdateUnreadCountDelegate? = nil, selectedIndexPath:IndexPath? = nil) {
        self.parentDelegate = delegate
        self.selectedIndexPath = selectedIndexPath
        
        self.conversationId = conversationId
        self.currentMessageTitle = title
        
        self.isOneToOne = isOneToOne
        self.hasToShowFirstMessage = conversation?.hasToShowFirstMessage() ?? false
        self.currentUserId = conversation?.user?.uid ?? 0
        
    }
    
    //MARK: Use to show/hide view new conversation ;)
    func checkNewConv() {
        if !isOneToOne {return}
        
        if  hasToShowFirstMessage {
            showViewNew()
        }
    }
    func showViewNew() {
        self.ui_constraint_tableview_top_top.priority = .defaultLow
        self.ui_constraint_tableview_top_margin.priority = .required
        self.ui_constraint_tableview_top_margin.constant = ui_view_new_conversation.frame.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    func hideViewNew() {
        self.ui_constraint_tableview_top_top.priority = .defaultLow
        self.ui_constraint_tableview_top_margin.priority = .required
        self.ui_constraint_tableview_top_margin.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - Keyboard Notif
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        self.ui_constraint_bottom_view_Tf.constant =  keyboardSize.height
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
        //hide empty view to prevent weird keyboard  ;)
        if messagesExtracted.messages.count == 0 {
            ui_view_empty.isHidden = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        ui_constraint_bottom_view_Tf.constant = bottomConstraint
        //Show empty view after preventing weird keyboard  ;)
        if messagesExtracted.messages.count == 0 {
            ui_view_empty.isHidden = false
        }
    }
    
    @objc func closeFromParams() {
        self.paramVC?.dismiss(animated: false)
        self.goBack()
    }
    
    @objc func userBlockedFromParams() {
        self.paramVC?.dismiss(animated: false)
        self.getDetailConversation()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Network -
    func getMessages() {
        if self.isLoading { return }
        if self.messagesExtracted.messages.isEmpty { self.ui_tableview.reloadData() }
        
        IHProgressHUD.show()
        
        self.isLoading = true
        MessagingService.getMessagesFor(conversationId: conversationId, currentPage: currentPage, per: numberOfItemsForWS) { messages, error in
            IHProgressHUD.dismiss()
            if let messages = messages {
                if self.currentPage > 1 {
                    self.messages.append(contentsOf: messages)
                }
                else {
                    self.messages = messages
                }
                
                self.checkNewConv()
                self.extractDict()
                
                self.ui_view_empty.isHidden = self.messagesExtracted.messages.count > 0
                
                self.ui_tableview.reloadData()
                
                if self.currentPage == 1 && self.messagesExtracted.messages.count + self.messagesForRetry.count > 0 {
                    DispatchQueue.main.async {
                        let indexPath = IndexPath(row: self.messagesExtracted.messages.count + self.messagesForRetry.count - 1, section: 0)
                        self.ui_tableview.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    }
                }
                
                self.parentDelegate?.updateUnreadCount(conversationId: self.conversationId, currentIndexPathSelected: self.selectedIndexPath)
            }
            self.setLoadingFalse()
        }
    }
    
    func getDetailConversation() {
        MessagingService.getDetailConversation(conversationId: conversationId) { conversation, error in
            if let conversation = conversation {
                if self.isOneToOne {
                    self.currentMessageTitle = conversation.members?.first(where: {$0.uid != self.meId})?.username
                    
                    let _title = self.currentMessageTitle ?? "messaging_message_title".localized
                    self.ui_top_view.updateTitle(title: _title)
                }
                self.currentConversation = conversation
                
                self.updateInputInfos()
            }
        }
    }
    
    func updateInputInfos() {
        if currentConversation?.hasBlocker() ?? false {
            ui_view_block.isHidden = false
        }
        else {
            ui_view_block.isHidden = true
        }
        
        let _name = currentMessageTitle ?? ""
        if currentConversation?.imBlocker() ?? false {
            ui_title_block.text = String.init(format: "message_user_blocked_by_me".localized, _name)
        }
        else {
            ui_title_block.text = String.init(format: "message_user_blocked_by_other".localized, _name)
        }
    }
    
    //To transform array -> array with dict date sections
    func extractDict() {
        let newMessagessSorted = PostMessage.getArrayOfDateSorted(messages: messages, isAscendant:true)
        
        var newMessages = [Any]()
        for (k,v) in newMessagessSorted {
            newMessages.append(k.dateString)
            for _msg in v {
                newMessages.append(_msg)
            }
        }
        
        let messagesSorted = MessagesSorted(messages: newMessages, datesSections: newMessagessSorted.count)
        
        self.messagesExtracted.messages.removeAll()
        self.messagesExtracted = messagesSorted
    }
    
    private func setLoadingFalse() {
        let timer = Timer(fireAt: Date().addingTimeInterval(1), interval: 0, target: self, selector: #selector(self.loadingAtFalse), userInfo: nil, repeats: false)
        
        RunLoop.current.add(timer, forMode: .common)
    }
    
    @objc private func loadingAtFalse() {
        self.isLoading = false
    }
    
    func sendMessage(messageStr:String, isRetry:Bool, positionForRetry:Int = 0) {
        self.ui_textview_message.text = nil
        ui_iv_bt_send.image = UIImage.init(named: "ic_send_comment_off")
        
        if self.isLoading { return }
        if self.messagesExtracted.messages.isEmpty { self.ui_tableview.reloadData() }
        
        IHProgressHUD.show()
        
        self.isLoading = true
        
        MessagingService.postCommentFor(conversationId: conversationId, message: messageStr) { message, error in
            IHProgressHUD.dismiss()
            if let _ = message {
                if isRetry {
                    self.messagesForRetry.remove(at: positionForRetry)
                }
                self.isLoading = false
                self.currentPage = 1
                self.getMessages()
                return
            }
            else {
                //Add custom post message for retry
                if isRetry { return }
                var postMsg = PostMessage()
                postMsg.content = messageStr
                postMsg.user = UserLightNeighborhood()
                postMsg.isRetryMsg = true
                
                self.messagesForRetry.append(postMsg)
                
                self.isStartEditing = false
                self.ui_view_empty.isHidden = true
                self.ui_tableview.reloadData()
                
                if self.messagesExtracted.messages.count + self.messagesForRetry.count > 0 {
                    DispatchQueue.main.async {
                        let indexPath = IndexPath(row: self.messagesExtracted.messages.count + self.messagesForRetry.count - 1, section: 0)
                        self.ui_tableview.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
                self.setLoadingFalse()
            }
        }
    }
    
    //MARK: - IBActions -
    @IBAction func action_tap_view(_ sender: Any) {
        _ = ui_textview_message.resignFirstResponder()
    }
    
    @IBAction func action_send_message(_ sender: Any) {
        self.closeKb(nil)
    }
   
    @IBAction func action_show_params(_ sender: Any) {
        if let navvc = storyboard?.instantiateViewController(withIdentifier: "params_nav") as? UINavigationController, let vc = navvc.topViewController as? ConversationParametersViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.userId = currentUserId
            vc.conversationId = conversationId
            vc.isOneToOne = isOneToOne
            vc.username = currentMessageTitle ?? "-"
            vc.imBlocker = currentConversation?.imBlocker() ?? false
            self.paramVC = vc
            self.present(navvc, animated: true, completion: nil)
            return
        }
    }
    
    @IBAction func action_show_user(_ sender: Any) {
        showUser(userId: currentUserId)
    }
    
    @IBAction func action_close_new_view(_ sender: Any) {
        self.hideViewNew()
    }
}

//MARK: - Tableview datasource/delegate -
extension ConversationDetailMessagesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesExtracted.messages.count + messagesForRetry.count //messages.count + messagesForRetry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if messagesForRetry.count > 0 {
            if indexPath.row >= messagesExtracted.messages.count {
                let message = messagesForRetry[indexPath.row - messagesExtracted.messages.count]
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellMe", for: indexPath) as! NeighborhoodMessageCell
                cell.populateCell(isMe: true, message: message, isRetry: true, positionRetry: indexPath.row - messagesExtracted.messages.count, delegate: self)
                return cell
            }
        }
        
        let messageExtracted = messagesExtracted.messages[indexPath.row]
        
        if let txt = messageExtracted as? String {
            let cell = tableView.dequeueReusableCell(withIdentifier: EventListSectionCell.identifier, for: indexPath) as! EventListSectionCell
            
            cell.populateMessageSectionCell(title: txt)
            
            return cell
        }
        
        let message = messageExtracted as! PostMessage
        var cellId = "cellOther"
        var isMe = false
        if message.user?.sid == self.meId {
            cellId = "cellMe"
            isMe = true
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! NeighborhoodMessageCell
        
        cell.populateCellConversation(isMe: isMe, message: message, isRetry: false, isOne2One: self.isOneToOne, delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoading { return }
        
        if indexPath.row == nbOfItemsBeforePagingReload && self.messages.count >= numberOfItemsForWS * currentPage {
            self.currentPage = self.currentPage + 1
            self.getMessages()
        }
    }
}

//MARK: - MJNavBackViewDelegate -
extension ConversationDetailMessagesViewController: MJNavBackViewDelegate {
    func goBack() {
        self.parentDelegate?.updateUnreadCount(conversationId: conversationId, currentIndexPathSelected: selectedIndexPath)
        self.dismiss(animated: true)
        self.navigationController?.dismiss(animated: true)
    }
}

//MARK: - UITextViewDelegate -
extension ConversationDetailMessagesViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if textView.text.count == 0 && text.count == 1 {
            ui_iv_bt_send.image = UIImage.init(named: "ic_send_comment")
        }
        else if textView.text.count == 1 && text.count == 0 {
            ui_iv_bt_send.image = UIImage.init(named: "ic_send_comment_off")
        }
        else if textView.text.count > 0 {
            ui_iv_bt_send.image = UIImage.init(named: "ic_send_comment")
        }
        else {
            ui_iv_bt_send.image = UIImage.init(named: "ic_send_comment_off")
        }
        
        return true
    }
    
    @objc func closeKb(_ sender:UIBarButtonItem?) {
        if let txt = ui_textview_message.text, txt != placeholderTxt, !txt.isEmpty {
            self.sendMessage(messageStr: txt, isRetry: false)
        }
        _ = ui_textview_message.resignFirstResponder()
    }
}

//MARK: - MessageCellSignalDelegate -
extension ConversationDetailMessagesViewController:MessageCellSignalDelegate {
    func signalMessage(messageId: Int) {}
    
    func retrySend(message: String,positionForRetry:Int) {
        self.sendMessage(messageStr: message, isRetry: true, positionForRetry: positionForRetry)
    }
    
    func showUser(userId:Int?) {
        guard let userId = userId else {
            return
        }
        
        if let navVC = UIStoryboard.init(name: StoryboardName.userDetail, bundle: nil).instantiateViewController(withIdentifier: "userProfileNavVC") as? UINavigationController {
            if let _homeVC = navVC.topViewController as? UserProfileDetailViewController {
                _homeVC.currentUserId = "\(userId)"
                
                self.present(navVC, animated: true)
            }
        }
    }
}

//MARK: - Protocol -
protocol UpdateUnreadCountDelegate:AnyObject {
    func updateUnreadCount(conversationId:Int, currentIndexPathSelected:IndexPath?)
}
