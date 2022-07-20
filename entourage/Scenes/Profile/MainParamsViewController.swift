//
//  MainParamsViewController.swift
//  entourage
//
//  Created by Jerome on 14/03/2022.
//

import UIKit
import FirebaseMessaging
import IHProgressHUD

class MainParamsViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    var versionInfo = ""
    var tokenInfo = ""
    var tokenPush:String? = nil
    var isStaging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_tableview?.dataSource = self
        ui_tableview?.delegate = self
        
        isStaging = EnvironmentConfigurationManager.sharedInstance.runsOnStaging
        
        if isStaging {
            self.versionInfo = "v:\(Bundle.main.versionName)"
            self.tokenInfo = "TOKEN Firebase:\nNon disponible"
            
            Messaging.messaging().token { token, error in
                if let _token = token {
                    self.tokenPush = _token
                    self.tokenInfo = "TOKEN Firebase:\n\(_token)"
                    self.ui_tableview?.reloadData()
                }
            }
        }
        else {
            self.versionInfo = "v:\(Bundle.main.versionName)"
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource -
extension MainParamsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellParams", for: indexPath) as! ParamMenuCell
            
            cell.populateCell(delegate: self)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellInfoDebug", for: indexPath) as! ParamsInfoCell
        cell.populateCell(info: versionInfo, token: tokenInfo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 && isStaging {
            if let _token = tokenPush {
                UIPasteboard.general.string = _token
                IHProgressHUD.showInfowithStatus("Information copiée dans le presse-papier")
            }
            else {
                IHProgressHUD.showInfowithStatus("pas de token")
            }
        }
    }
}

//MARK: - MainParamsMenuDelegate -
extension MainParamsViewController:MainParamsMenuDelegate {
    func actionMenu(type: MainParamsMenuType) {
        switch type {
        case .Notifs:
            //TODO: V2
            Logger.print("\(type)")
        case .Help:
            let sb = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "paramsHelpVC")
            self.navigationController?.present(vc, animated: true, completion: nil)
        case .Unlock:
            //TODO:V2
            Logger.print("\(type)")
        case .Share:
            let textShare = String.init(format: "menu_info_text_share".localized, ENTOURAGE_BITLY_LINK)
            let activityVC = UIActivityViewController.init(activityItems: [textShare], applicationActivities: nil)
            self.navigationController?.present(activityVC, animated: true, completion: nil)
        case .Logout:
            showPopLogout()
        case .Suppress:
            showPopSuppress()
        }
    }
    
    func showPopLogout() {
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "params_logout_pop_logout".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
        let buttonCancel = MJAlertButtonType(title: "params_logout_pop_cancel".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        
        customAlert.configureAlert(alertTitle: "params_logout_pop_title".localized, message: "params_logout_pop_message".localized, buttonrightType: buttonCancel, buttonLeftType: buttonAccept, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35,parentVC:self)
        
        customAlert.alertTagName = .Logout
        customAlert.delegate = self
        customAlert.show()
    }
    
    func showPopSuppress() {
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "params_suppress_pop_suppress".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
        let buttonCancel = MJAlertButtonType(title: "params_suppress_pop_cancel".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        
        customAlert.configureAlert(alertTitle: "params_suppress_pop_title".localized, message: "params_suppress_pop_message".localized, buttonrightType: buttonCancel, buttonLeftType: buttonAccept, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35,parentVC:self)
        
        customAlert.alertTagName = .Suppress
        customAlert.delegate = self
        customAlert.show()
    }
}

//MARK: - MJAlertControllerDelegate -
extension MainParamsViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag:MJAlertTAG) {
        switch alertTag {
        case .Suppress:
            UserService.deleteUserAccount { error in
                if let error = error {
                    let errorMessage = String.init(format: "params_account_not_deleted".localized, error.message)
                    IHProgressHUD.showError(withStatus: errorMessage)
                    return
                }
                NotificationCenter.default.post(name: NSNotification.Name(notificationLoginError), object: self)
                IHProgressHUD.showSuccesswithStatus("params_account_deleted".localized)
            }
        case .Logout:
            NotificationCenter.default.post(name: NSNotification.Name(notificationLoginError), object: self)
        case .None,.AcceptSettings:
            break
        }
    }
    
    func validateRightButton(alertTag:MJAlertTAG) {}
    func closePressed(alertTag:MJAlertTAG) {}
}
