//
//  NeighborhoodDetailMessagesViewController.swift
//  entourage
//
//  Created by Jerome on 16/05/2022.
//

import UIKit
import IHProgressHUD

class NeighborhoodDetailMessagesViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_view_txtview: UIView!
    
    @IBOutlet weak var ui_iv_bt_send: UIImageView!
    @IBOutlet weak var ui_view_button_send: UIView!
    @IBOutlet weak var ui_constraint_bottom_view_Tf: NSLayoutConstraint!
    @IBOutlet weak var ui_textview_message: MJTextViewPlaceholder!
    
    @IBOutlet weak var ui_title_not_auth: UILabel!
    @IBOutlet weak var ui_view_not_auth: UIView!
    
    @IBOutlet weak var ui_view_empty: UIView!
    @IBOutlet weak var ui_title_empty: UILabel!
    
    var neighborhoodId:Int = 0
    var parentCommentId:Int = 0
    var neighborhoodName = ""
    var isGroupMember = false
    
    var messages = [PostMessage]()
    var meId:Int = 0
    
    var messagesForRetry = [PostMessage]()
    
    let placeholderTxt = "neighborhood_comments_placeholder_discut".localized
    
    var bottomConstraint:CGFloat = 0
    var isStartEditing = false
    
    var makeErrorForRetry = false //TODO: a supprimer après tests
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_top_view.populateView(title: "neighborhood_comments_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: false)
        
        ui_title_empty.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_title_empty.text = "neighborhood_no_messageComment".localized
        ui_view_empty.isHidden = true
        
        ui_title_not_auth.setupFontAndColor(style: ApplicationTheme.getFontLegend())
        ui_title_not_auth.text = String.init(format: "neighborhood_messageComment_notAuth".localized, neighborhoodName)
        ui_view_not_auth.isHidden = isGroupMember
        
        ui_view_txtview.layer.borderWidth = 1
        ui_view_txtview.layer.borderColor = UIColor.appOrange.cgColor
        ui_view_txtview.layer.cornerRadius = ui_view_txtview.frame.height / 2
        
        ui_textview_message.delegate = self
        ui_textview_message.hasToCenterTextVerticaly = true
        
        ui_view_button_send.backgroundColor = .clear
        ui_iv_bt_send.image = UIImage.init(named: "ic_send_comment_off")
        
        
        let _width = UIApplication.shared.delegate?.window??.frame.width ?? view.frame.size.width
        let buttonDone = UIBarButtonItem(title: "neighborhood_comments_send".localized, style: .plain, target: self, action: #selector(closeKb(_:)))
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
        
        if isGroupMember && isStartEditing {
            _ = ui_textview_message.becomeFirstResponder()
        }
    }
    
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
        if messages.count == 0 {
            ui_view_empty.isHidden = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        ui_constraint_bottom_view_Tf.constant = bottomConstraint
        //Show empty view after preventing weird keyboard  ;)
        if messages.count == 0 {
            ui_view_empty.isHidden = false
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Network -
    func getMessages() {
        NeighborhoodService.getCommentsFor(neighborhoodId: neighborhoodId, parentPostId: parentCommentId) { messages, error in
            Logger.print("***** Messages ? \(messages) - Error: \(error?.message)")
            if let messages = messages {
                let hasMessages = self.messages.count > 0
                self.messages = messages
                self.ui_view_empty.isHidden = self.messages.count > 0
                
                if self.isStartEditing && self.messages.count == 0 {
                    self.isStartEditing = false
                    self.ui_view_empty.isHidden = true
                }
                
                //Scroll to top only if we have already datas loaded
                if hasMessages {
                    let indexPath = IndexPath(row: 0, section: 0)
                    DispatchQueue.main.async {
                        self.ui_tableview?.scrollToRow(at: indexPath, at: .top, animated: true)
                        self.ui_tableview.reloadData()
                    }
                }
                else {
                    self.ui_tableview.reloadData()
                }
                return
            }
            if self.isStartEditing {
                self.isStartEditing = false
                self.ui_view_empty.isHidden = true
            }
            else {
                self.ui_view_empty.isHidden = false
            }
            self.ui_tableview.reloadData()
        }
    }
    
    func sendMessage(message:String, isRetry:Bool, positionForRetry:Int = 0) {
        self.ui_textview_message.text = nil
        ui_iv_bt_send.image = UIImage.init(named: "ic_send_comment_off")
        NeighborhoodService.postCommentFor(neighborhoodId: neighborhoodId, parentPostId: parentCommentId, message: message, hasError: makeErrorForRetry) { error in
            
            if error == nil {
                if isRetry {
                    self.messagesForRetry.remove(at: positionForRetry)
                }
                self.getMessages()
                return
            }
            else {
                //Add custom post message for retry
                if isRetry { return }
                var postMsg = PostMessage()
                postMsg.content = message
                postMsg.user = UserLightNeighborhood()
                postMsg.isRetryMsg = true
                
                if self.messagesForRetry.count == 0 {
                    self.messagesForRetry.append(postMsg)
                }
                else {
                    self.messagesForRetry.insert(postMsg, at: 0)
                }
                
                self.isStartEditing = false
                self.ui_view_empty.isHidden = true
                if self.messages.count + self.messagesForRetry.count > 1 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    DispatchQueue.main.async {
                        self.ui_tableview?.scrollToRow(at: indexPath, at: .top, animated: true)
                        self.ui_tableview.reloadData()
                    }
                }
                else {
                    self.ui_tableview.reloadData()
                }
            }
        }
    }
    
    @IBAction func action_send_message(_ sender: Any) {
        self.closeKb(nil)
    }
    
    @IBAction func action_signal(_ sender: Any) {
        if let navvc = UIStoryboard.init(name: "Neighborhood_Report", bundle: nil).instantiateViewController(withIdentifier: "reportNavVC") as? UINavigationController, let vc = navvc.topViewController as? ReportGroupMainViewController {
            vc.groupId = neighborhoodId
            vc.postId = parentCommentId
            vc.parentDelegate = self
            vc.signalType = .publication
            self.present(navvc, animated: true)
        }
    }
    //TODO: a supprimer après tests + mod WS
    @IBAction func action_error(_ sender: UISwitch) {
        if sender.isOn {
            makeErrorForRetry = true
        }
        else {
            makeErrorForRetry = false
        }
    }
}

//MARK: - Tableview datasource/delegate -
extension NeighborhoodDetailMessagesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count + messagesForRetry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if messagesForRetry.count > 0 {
            if indexPath.row < messagesForRetry.count {
                let message = messagesForRetry[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellMe", for: indexPath) as! NeighborhoodMessageCell
                cell.populateCell(isMe: true, message: message, isRetry: true, positionRetry: indexPath.row, delegate: self)
                return cell
            }
        }
        
        let message = messages[indexPath.row - messagesForRetry.count]
        var cellId = "cellOther"
        var isMe = false
        if message.user?.sid == self.meId {
            cellId = "cellMe"
            isMe = true
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! NeighborhoodMessageCell
        cell.populateCell(isMe: isMe, message: message, isRetry: false, delegate: self)
        return cell
    }
}

//MARK: - MJNavBackViewDelegate -
extension NeighborhoodDetailMessagesViewController: MJNavBackViewDelegate {
    func goBack() {
        self.dismiss(animated: true)
        self.navigationController?.dismiss(animated: true)
    }
}

//MARK: - UITextViewDelegate -
extension NeighborhoodDetailMessagesViewController: UITextViewDelegate {
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
            self.sendMessage(message: txt, isRetry: false)
        }
        _ = ui_textview_message.resignFirstResponder()
    }
}

//MARK: - NeighborhoodMessageCellDelegate -
extension NeighborhoodDetailMessagesViewController:NeighborhoodMessageCellDelegate {
    func signalMessage(messageId: Int) {
        if let navvc = UIStoryboard.init(name: "Neighborhood_Report", bundle: nil).instantiateViewController(withIdentifier: "reportNavVC") as? UINavigationController, let vc = navvc.topViewController as? ReportGroupMainViewController {
            vc.groupId = neighborhoodId
            vc.postId = messageId
            vc.parentDelegate = self
            vc.signalType = .comment
            self.present(navvc, animated: true)
        }
    }
    
    func retrySend(message: String,positionForRetry:Int) {
        self.sendMessage(message: message, isRetry: true, positionForRetry: positionForRetry)
    }
}

//MARK: - GroupDetailDelegate -
extension NeighborhoodDetailMessagesViewController:GroupDetailDelegate {
    func showMessage(signalType:GroupDetailSignalType) {
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "OK".localized, titleStyle:ApplicationTheme.getFontCourantRegularNoir(size: 18, color: .white), bgColor: .appOrange, cornerRadius: -1)
        let title = signalType == .comment ? "report_comment_title".localized : "report_publication_title".localized
        
        alertVC.configureAlert(alertTitle: title, message: "report_group_message_success".localized, buttonrightType: buttonCancel, buttonLeftType: nil, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true, parentVC: self)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            alertVC.show()
        }
    }
}
