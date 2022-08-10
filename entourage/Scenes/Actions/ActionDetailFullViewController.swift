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
    
    var action:Action? = nil
    var actionId = 0
    var isContrib = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        
        ui_top_view.backgroundColor = .appBeigeClair
        let _title = action?.title ?? "action"
        ui_top_view.populateCustom(title: _title, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: nil, imageName: nil, backgroundColor: .clear, delegate: self, showSeparator: true, cornerRadius: nil, isClose: false, marginLeftButton: nil,doubleRightMargin: true)
       
        getAction()
        setupBottomViews()
        
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
        ActionsService.getDetailAction(isContrib: isContrib, actionId: actionId) { action, error in
            if let action = action {
                self.action = action
                self.showHideBottomViews()
                self.ui_tableview.reloadData()
                self.ui_top_view.updateTitle(title: action.title ?? "action_your".localized)
            }
        }
    }
    
    func sendCancelAction() {
        IHProgressHUD.show()
        ActionsService.cancelAction(isContrib: isContrib, actionId: actionId) { action, error in
            IHProgressHUD.dismiss()
            if error == nil {
                self.action?.setCancel()
                self.showHideBottomViews()
                self.ui_tableview.reloadData()
            }
        }
    }
    
    func showHideBottomViews() {
        if action?.isCanceled() ?? false {
            ui_view_contact.isHidden = true
            ui_view_my.isHidden = true
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
        showWIP(parentVC: self)
    }
    
    @IBAction func action_signal(_ sender: Any) {
        if let  vc = UIStoryboard.init(name: StoryboardName.neighborhoodReport, bundle: nil).instantiateViewController(withIdentifier: "reportGroupMainVC") as? ReportGroupMainViewController {
            vc.actionId = actionId
            vc.parentDelegate = self
            vc.signalType = isContrib ? .actionContrib : .actionSolicitation
            self.present(vc, animated: true)
        }
    }
    
    func showPopCancel() {
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "params_cancel_action_pop_bt_delete".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        let buttonCancel = MJAlertButtonType(title: "params_cancel_action_pop_bt_cancel".localized, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), bgColor: .appOrangeLight_50, cornerRadius: -1)
        
        customAlert.configureAlert(alertTitle: "params_cancel_action_pop_title".localized, message: "params_cancel_action_pop_message".localized, buttonrightType: buttonAccept, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35,parentVC:self)
        
        customAlert.alertTagName = .Suppress
        customAlert.delegate = self
        customAlert.show()
    }
}

//MARK: - Tableview Datasource/delegate -
extension ActionDetailFullViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = action {
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
    func showMessage(signalType:GroupDetailSignalType) {
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "OK".localized, titleStyle:ApplicationTheme.getFontCourantRegularNoir(size: 18, color: .white), bgColor: .appOrange, cornerRadius: -1)
        
        let _title = isContrib ? "report_contrib_title".localized : "report_solicitation_title".localized
        alertVC.configureAlert(alertTitle: _title, message: "report_group_message_success".localized, buttonrightType: buttonCancel, buttonLeftType: nil, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true, parentVC: self)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            alertVC.show()
        }
    }
}

//MARK: - MJAlertControllerDelegate -
extension ActionDetailFullViewController: MJAlertControllerDelegate {
    
    
    func validateRightButton(alertTag:MJAlertTAG) {
        if alertTag == .Suppress {
            self.sendCancelAction()
        }
    }
    
    func validateLeftButton(alertTag:MJAlertTAG) {}
    func closePressed(alertTag:MJAlertTAG) {}
    func selectedChoice(position: Int) {}
}

//MARK: - ActionFullAuthorCellDelegate -
extension ActionDetailFullViewController:ActionFullAuthorCellDelegate {
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
