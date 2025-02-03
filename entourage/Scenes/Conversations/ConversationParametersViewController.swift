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
    var imBlocker = false
    var userId:Int? = nil
    var conversationId:Int? = nil
    var isCreator = false
    var username:String = ""
    var isSeveral = false
    
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
        var _convId = ""
        if self.conversationId != 0 {
            _convId = String(conversationId)
        }
        MessagingService.getDetailConversation(conversationId: _convId) { conversation, error in
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
    
    func sendBlockUser() {
        MessagingService.blockUser(userId: userId!) { error in
            if error == nil {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationMessagesUpdateUserBlocked), object: nil)
            }
            self.showPopValideBlock()
        }
    }
    
    func showPopLeave() {
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "params_leave_conv_pop_bt_quit".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        let buttonCancel = MJAlertButtonType(title: "params_leave_conv_pop_bt_cancel".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
        
        customAlert.configureAlert(alertTitle: "params_leave_conv_pop_title".localized, message: "params_leave_conv_pop_message".localized, buttonrightType: buttonAccept, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35)
        
        customAlert.alertTagName = .None
        customAlert.delegate = self
        customAlert.show()
    }
    
    func showUser() {
        guard let userId = userId else {
            return
        }
        
        if let navVC = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil).instantiateViewController(withIdentifier: "profileFull") as? UINavigationController {
            if let _homeVC = navVC.topViewController as? ProfilFullViewController {
                _homeVC.userIdToDisplay = "\(userId)"
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
    
    func showPopBlockUser() {
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "params_block_user_conv_pop_bt_quit".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        let buttonCancel = MJAlertButtonType(title: "params_block_user_conv_pop_bt_cancel".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
        
        let desc = String.init(format: "params_block_user_conv_pop_message".localized, username)
        customAlert.configureAlert(alertTitle: "params_block_user_conv_pop_title".localized, message:desc, buttonrightType: buttonAccept, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35)
        
        customAlert.alertTagName = .Suppress
        customAlert.delegate = self
        customAlert.show()
    }
    
    func showPopValideBlock() {
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "params_block_user_conv_pop_validate_bt".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        
        let _title = String.init(format: "params_block_user_conv_pop_validate_title".localized, username)
        customAlert.configureAlert(alertTitle: _title , message: "params_block_user_conv_pop_validate_subtitle".localized, buttonrightType: buttonAccept, buttonLeftType: nil, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35)
        
        customAlert.alertTagName = .None
        customAlert.show()
        
        //TODO: refresh 
    }
}

//MARK: - MJAlertControllerDelegate -
extension ConversationParametersViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag:MJAlertTAG) {}
    
    func validateRightButton(alertTag:MJAlertTAG) {
        if alertTag == .None {
            self.sendLeaveConversation()
        }
        if alertTag == .Suppress {
            self.sendBlockUser()
        }
    }
    func closePressed(alertTag:MJAlertTAG) {}
    
    func selectedChoice(position: Int) {}
}

//MARK: - Tableview Datasource/delegate -
extension ConversationParametersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Si c'est une conversation entre deux personnes et l'utilisateur n'est pas un bloqueur
        if isOneToOne {
            return imBlocker ? 2 : 3 - (isSeveral ? 1 : 0)
        } else {
            // Si c'est une conversation de groupe et l'utilisateur est le créateur
            return isCreator ? 2 : 3
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        // Ajustement des indices si "isSeveral" est vrai et qu'il s'agit d'une conversation un à un
        let isBlockCellRemoved = isOneToOne && isSeveral
        let adjustedRow = isBlockCellRemoved && row >= 2 ? row + 1 : row

        switch adjustedRow {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_arrow", for: indexPath) as! ConversationParamCell
            cell.populateCell(title: isOneToOne ? "conv_param_title_profil".localized : "conv_param_title_members".localized, subtitle: nil, isTitleOrange: false, pictoStr: "ic_user_conv")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_subtitle", for: indexPath) as! ConversationParamCell
            cell.populateCell(title: isOneToOne ? "conv_param_title_signal".localized : "conv_param_title_signal_action".localized, subtitle: isOneToOne ? "conv_param_subtitle_signal".localized : "conv_param_subtitle_signal_action".localized, isTitleOrange: true, pictoStr: "ic_signal_orange")
            return cell
        case 2:
            if isOneToOne && !isSeveral {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_subtitle", for: indexPath) as! ConversationParamCell
                let subtitle = String.init(format: "conv_param_subtitle_block".localized, username)
                cell.populateCell(title: "conv_param_title_block".localized , subtitle: subtitle, isTitleOrange: true, pictoStr: "ic_user_block")
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_alone", for: indexPath) as! ConversationParamCell
                cell.populateCell(title: "conv_param_qui_action".localized, subtitle: nil, isTitleOrange: true, pictoStr: "ic_leave_conv", hideSeparator: true)
                return cell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_alone", for: indexPath) as! ConversationParamCell
            cell.populateCell(title: "conv_param_qui_action".localized, subtitle: nil, isTitleOrange: true, pictoStr: "ic_leave_conv", hideSeparator: true)
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
            if isOneToOne {
                showPopBlockUser()
                return
            }
            showPopLeave()
        }
    }
}

//MARK: - GroupDetailDelegate -
extension ConversationParametersViewController: GroupDetailDelegate {
    func translateItem(id: Int) {
        //TODO TRANSLATE
    }
    
    func publicationDeleted() {
        if !isOneToOne {
            getConversation()
        }
        self.ui_tableview.reloadData()
    }
    
    func showMessage(signalType:GroupDetailSignalType) {
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "OK".localized, titleStyle:ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        
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
