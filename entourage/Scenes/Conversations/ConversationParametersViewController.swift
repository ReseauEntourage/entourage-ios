//
//  ConversationParametersViewController.swift
//  entourage
//
//  Created by Jerome on 26/08/2022.
//

import UIKit

class ConversationParametersViewController: BasePopViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    var isOneToOne = true
    var userId:Int? = nil
    var conversationId:Int? = nil
    var isCreator = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_top_view.populateView(title: "conversation_params_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self,backgroundColor: .appBeigeClair, isClose: true)
        
        if !isOneToOne {
            getConversation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let _ = conversationId else {
            self.goBack()
            return
        }
        self.navigationController?.hideTransparentNavigationBar()
    }
    
    //MARK: - Network
    
    func getConversation() {
        guard let conversationId = conversationId else {
            self.goBack()
            return
        }
        
        MessagingService.getDetailConversation(conversationId: conversationId) { conversation, error in
            if let conversation = conversation,let isCreator = conversation.isCreator {
                self.isCreator = isCreator
            }
            
            self.ui_tableview.reloadData()
        }
    }
    
    func sendLeaveConversation() {
        guard let conversationId = conversationId else {
            return
        }
        
        MessagingService.leaveConversation(conversationId: conversationId) { error in
            if error == nil {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationMessagesUpdate), object: nil)
            }
        }
    }
    
    func showPopLeave() {
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "params_leave_conv_pop_bt_quit".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        let buttonCancel = MJAlertButtonType(title: "params_leave_conv_pop_bt_cancel".localized, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), bgColor: .appOrangeLight_50, cornerRadius: -1)
        
        customAlert.configureAlert(alertTitle: "params_leave_conv_pop_title".localized, message: "params_leave_conv_pop_message".localized, buttonrightType: buttonAccept, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35)
        
        customAlert.alertTagName = .None
        customAlert.delegate = self
        customAlert.show()
    }
    
    func showUser() {
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
    func showMembers() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "list_membersVC") as? ConversationListMembersViewController {
            vc.conversationId = conversationId
            vc.modalPresentationStyle = .currentContext
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func signalConversation() {
        if let  vc = UIStoryboard.init(name: StoryboardName.neighborhoodReport, bundle: nil).instantiateViewController(withIdentifier: "reportGroupMainVC") as? ReportGroupMainViewController {
            vc.modalPresentationStyle = .currentContext
            vc.parentDelegate = self
            vc.signalType = .conversation
            vc.conversationId = conversationId
            self.navigationController?.present(vc, animated: true)
        }
    }
}

//MARK: - MJAlertControllerDelegate -
extension ConversationParametersViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag:MJAlertTAG) {}
    
    func validateRightButton(alertTag:MJAlertTAG) {
        if alertTag == .None {
            self.sendLeaveConversation()
        }
    }
    func closePressed(alertTag:MJAlertTAG) {}
    
    func selectedChoice(position: Int) {}
}

//MARK: - Tableview Datasource/delegate -
extension ConversationParametersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isOneToOne ? 2 : isCreator ? 2 : 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_arrow", for: indexPath) as! ConversationParamCell
            cell.populateCell(title: isOneToOne ? "conv_param_title_profil".localized : "conv_param_title_members".localized, subtitle: nil, isTitleOrange: false, pictoStr: "ic_user_conv")
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_subtitle", for: indexPath) as! ConversationParamCell
            //One2one -> signal /  Signal
            cell.populateCell(title: isOneToOne ? "conv_param_title_signal".localized : "conv_param_title_signal_action".localized, subtitle: isOneToOne ? "conv_param_subtitle_signal".localized : "conv_param_subtitle_signal_action".localized, isTitleOrange: true, pictoStr: "ic_signal_orange")
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_alone", for: indexPath) as! ConversationParamCell
            //quit conv
            cell.populateCell(title: "conv_param_qui_action".localized, subtitle: nil,isTitleOrange: true, pictoStr: "ic_leave_conv", hideSeparator: true)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            if isOneToOne {
                self.showUser()
            }
            else {
                self.showMembers()
            }
        case 1:
            self.signalConversation()
        default:
            showPopLeave()
        }
    }
}

//MARK: - GroupDetailDelegate -
extension ConversationParametersViewController: GroupDetailDelegate {
    func showMessage(signalType:GroupDetailSignalType) {
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "OK".localized, titleStyle:ApplicationTheme.getFontCourantRegularNoir(size: 18, color: .white), bgColor: .appOrange, cornerRadius: -1)
        
        alertVC.configureAlert(alertTitle: "report_conversation_title".localized, message: "report_group_message_success".localized, buttonrightType: buttonCancel, buttonLeftType: nil, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            alertVC.show()
        }
    }
}

//MARK: - MJNavBackViewDelegate -
extension ConversationParametersViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}
