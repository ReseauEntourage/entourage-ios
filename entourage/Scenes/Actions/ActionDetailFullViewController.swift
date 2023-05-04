//
//  ActionDetailFullViewController.swift
//  entourage
//
//  Created by Jerome on 05/08/2022.
//

import UIKit
import IHProgressHUD

class ActionDetailFullViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    
    @IBOutlet weak var ui_title_contact: UILabel!
    @IBOutlet weak var ui_view_contact: UIView!
    
    @IBOutlet weak var ui_view_my: UIView!
    @IBOutlet weak var ui_title_delete: UILabel!
    @IBOutlet weak var ui_title_edit: UILabel!
    
    @IBOutlet weak var ui_view_cancel: UIView!
    @IBOutlet weak var ui_view_edit: UIView!
    
    
    @IBOutlet weak var ui_cancel_button: UIButton!
    @IBOutlet weak var ui_cancel_subtitle: UILabel!
    @IBOutlet weak var ui_cancel_title: UILabel!
    @IBOutlet weak var ui_view_empty: UIView!
    @IBOutlet weak var ui_button_share: UIButton!
    
    
    var action:Action? = nil
    var actionId = 0
    var hashedActionId = ""
    var isContrib = false
    
    var parentVC:UIViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        
        ui_top_view.backgroundColor = .appBeigeClair
        let _title = isContrib ? "Contrib".localized : "Demand".localized
        ui_top_view.populateCustom(title: _title, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: nil, imageName: nil, backgroundColor: .clear, delegate: self, showSeparator: true, cornerRadius: nil, isClose: false, marginLeftButton: nil,doubleRightMargin: true)
        
        getAction()
        setupBottomViews()
        setupCancelView()
        ui_view_empty.isHidden = true
        ui_view_contact.isHidden = true
        ui_view_my.isHidden = true
        
        
        //Notif for updating action infos
        NotificationCenter.default.addObserver(self, selector: #selector(updateAction), name: NSNotification.Name(rawValue: kNotificationActionUpdate), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateAction() {
        getAction()
    }
    
    func getAction() {
        var _actionId = ""
        if actionId != 0 {
            _actionId = String(actionId)
        }else if hashedActionId != "" {
            _actionId = hashedActionId
        }
        ActionsService.getDetailAction(isContrib: isContrib, actionId: _actionId) { action, error in
            if let action = action {
                self.action = action
                self.showHideBottomViews()
                self.ui_tableview.reloadData()
                
                if action.isContrib() {
                    AnalyticsLoggerManager.logEvent(name: Help_view_contrib_detail)
                }
                else {
                    AnalyticsLoggerManager.logEvent(name: Help_view_demand_detail)
                }
                
            }
            else {
                self.goBack()
            }
        }
    }
    
    func showHideBottomViews() {
        if action?.isCanceled() ?? false {
            ui_view_contact.isHidden = true
            ui_view_my.isHidden = true
            
            ui_view_empty.isHidden = false
            
            ui_cancel_subtitle.text = action?.isContrib() ?? false ? "action_view_canceled_contrib_subtitle".localized : "action_view_canceled_demand_subtitle".localized
            let _btTitle = action?.isContrib() ?? false ? "action_view_canceled_contrib_button".localized : "action_view_canceled_demand_button".localized
            ui_cancel_button.setTitle(_btTitle, for: .normal)
            
            ui_top_view.changeTitleColor(titleColor: .appGris112)
            ui_button_share.isHidden = true
        }
        else if action?.isMine() ?? false {
            ui_view_contact.isHidden = true
            ui_view_my.isHidden = false
        }
        else {
            ui_view_contact.isHidden = false
            ui_view_my.isHidden = true
        }
    }
    
    func setupBottomViews() {
        ui_view_contact.layer.cornerRadius = ui_view_contact.frame.height / 2
        ui_view_edit.layer.cornerRadius = ui_view_contact.frame.height / 2
        
        ui_view_cancel.layer.cornerRadius = ui_view_contact.frame.height / 2
        ui_view_cancel.layer.borderWidth = 1
        ui_view_cancel.layer.borderColor = UIColor.appOrange.cgColor
        ui_title_edit.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
        ui_title_contact.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
        ui_title_delete.setupFontAndColor(style: ApplicationTheme.getFontBoutonOrange())
        ui_button_share.layer.cornerRadius = 17
    }
    
    func setupCancelView() {
        ui_cancel_title.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        ui_cancel_subtitle.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_cancel_button.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
        ui_cancel_title.text = "action_view_canceled_title".localized
        ui_cancel_button.layer.cornerRadius = ui_cancel_button.frame.height / 2
    }
    
    
    @IBAction func action_share(_ sender: Any) {
        var stringUrl = "https://"
        var title = ""
        if NetworkManager.sharedInstance.getBaseUrl().contains("preprod"){
            stringUrl = stringUrl + "preprod.entourage.social/app/"
        }else{
            stringUrl = stringUrl + "www.entourage.social/app/"
        }
        if let _action = action {
            if _action.isContrib(){
                stringUrl = stringUrl + "contributions/" + _action.uuid_v2
                title = "share_contribution".localized
            }else{
                stringUrl = stringUrl + "solicitations/" + _action.uuid_v2
                title = "share_solicitation".localized
            }
        }
        let url = URL(string: stringUrl)!
        let shareText = "\(title)\n\n\(stringUrl)"
        
        let activityViewController = UIActivityViewController(activityItems: [title, url], applicationActivities: nil)
          // Présenter l’UIActivityViewController
        let viewController = self
          viewController.present(activityViewController, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func action_show_actions(_ sender: Any) {
        self.navigationController?.dismiss(animated: true) {
            self.parentVC?.dismiss(animated: true)
            if self.action?.isContrib() ?? false {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationActionShowContrib), object: nil)
            }
            else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationActionShowSolicitation), object: nil)
            }
            NotificationCenter.default.post(name: NSNotification.Name(kNotificationActionsUpdate), object: nil)
        }
    }
    
    @IBAction func action_cancel(_ sender: Any) {
        showPopCancel()
    }
    
    @IBAction func action_edit(_ sender: Any) {
        guard let action = action else {
            return
        }
        
        let sb = UIStoryboard.init(name: StoryboardName.actionCreate, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "actionEditVCMain") as? ActionEditMainViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.isContrib = isContrib
            vc.parentController = self
            vc.currentAction = action
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func action_contact(_ sender: Any) {
        guard let user = action?.author else {return}
        
        if action?.isContrib() ?? false {
            AnalyticsLoggerManager.logEvent(name: Help_action_contrib_contact)
        }
        else {
            AnalyticsLoggerManager.logEvent(name: Help_action_demand_contact)
        }
        
        IHProgressHUD.show()
        MessagingService.createOrGetConversation(userId: "\(user.uid)") { conversation, error in
            IHProgressHUD.dismiss()
            
            if let conversation = conversation {
                self.showConversation(conversation: conversation, username: user.displayName)
                return
            }
            var errorMsg = "message_error_create_conversation".localized
            if let error = error {
                errorMsg = error.message
            }
            IHProgressHUD.showError(withStatus: errorMsg)
        }
    }
    
    private func showConversation(conversation:Conversation?, username:String) {
        DispatchQueue.main.async {
            if let convId = conversation?.uid {
                let sb = UIStoryboard.init(name: StoryboardName.messages, bundle: nil)
                if let vc = sb.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
                    vc.setupFromOtherVC(conversationId: convId, title: username, isOneToOne: true, conversation: conversation)
                    
                    self.present(vc, animated: true)
                }
            }
        }
    }
    

    
    
    
    func showPopCancel() {
        let homeVC = ActionDeletePopsViewController()
        homeVC.configureCongrat( parentVC: self.navigationController, isContrib: isContrib, actionId: actionId, delegate: self)
        homeVC.show()
    }
    
}

//MARK: - Tableview Datasource/delegate -
extension ActionDetailFullViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let action = action, !action.isCanceled() {
            return 3
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "topCell", for: indexPath) as! ActionFullTopCell
            cell.populateCell(action: action!)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellMap", for: indexPath) as! ActionFullMapCell
            cell.populateCell(action: action!)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellAuthor", for: indexPath) as! ActionFullAuthorCell
            cell.populateCell(action: action!, delegate: self)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            if let navVC = UIStoryboard.init(name: StoryboardName.userDetail, bundle: nil).instantiateViewController(withIdentifier: "userProfileNavVC") as? UINavigationController {
                if let _homeVC = navVC.topViewController as? UserProfileDetailViewController {
                    guard let userId = action?.author?.uid else {return}
                    _homeVC.currentUserId = "\(userId)"
                    
                    self.navigationController?.present(navVC, animated: true)
                }
            }
        }
    }
}

//MARK: - GroupDetailDelegate -
extension ActionDetailFullViewController: GroupDetailDelegate {
    func publicationDeleted() {
        getAction()
        self.ui_tableview.reloadData()
    }
    
    func showMessage(signalType:GroupDetailSignalType) {
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "OK".localized, titleStyle:ApplicationTheme.getFontCourantRegularNoir(size: 18, color: .white), bgColor: .appOrange, cornerRadius: -1)
        
        let _title = isContrib ? "report_contrib_title".localized : "report_solicitation_title".localized
        alertVC.configureAlert(alertTitle: _title, message: "report_group_message_success".localized, buttonrightType: buttonCancel, buttonLeftType: nil, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            alertVC.show()
        }
    }
}

//MARK: - ActionDeletePopDelegate -
extension ActionDetailFullViewController: ActionDeletePopDelegate {
    func canceledAction(isCancel: Bool) {
        if isCancel {
            self.action?.setCancel()
            self.showHideBottomViews()
            self.ui_tableview.reloadData()
        }
    }
}

//MARK: - ActionFullAuthorCellDelegate -
extension ActionDetailFullViewController:ActionFullAuthorCellDelegate {
    func goSignal() {
        if let vc = UIStoryboard.init(name: StoryboardName.neighborhoodReport, bundle: nil).instantiateViewController(withIdentifier: "reportGroupMainVC") as? ReportGroupMainViewController {
             vc.actionId = actionId
             vc.parentDelegate = self
             vc.signalType = isContrib ? .actionContrib : .actionSolicitation
             self.present(vc, animated: true)
           }
    }
    
    func showCharte() {
        if let  vc = UIStoryboard.init(name: StoryboardName.actions, bundle: nil).instantiateViewController(withIdentifier: "params_CGU_VC") as? ActionParamsCGUViewController {
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.present(vc, animated: true)
        }
    }
}

//MARK: - MJNavBackViewDelegate -
extension ActionDetailFullViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}
