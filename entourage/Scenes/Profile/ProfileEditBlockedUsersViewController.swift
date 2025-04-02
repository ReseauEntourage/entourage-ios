//
//  ProfileEditBlockedUsersViewController.swift
//  entourage
//
//  Created by - on 24/11/2022.
//

import UIKit

class ProfileEditBlockedUsersViewController: BasePopViewController {
    
    @IBOutlet weak var ui_lbl_info: UILabel!
    @IBOutlet weak var ui_error_view: MJErrorInputView!
    @IBOutlet weak var ui_button_validate: UIButton!
    @IBOutlet weak var ui_tableview: UITableView!
    
    @IBOutlet weak var ui_view_empty: UIView!
    @IBOutlet weak var ui_title_empty: UILabel!
    
    var userBlocked = [UserBlocked]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_top_view.populateView(title: "params_unlock".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
        
        
        self.ui_lbl_info.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        ui_lbl_info.text = "settingsUnblockUserInfo".localized
        
        ui_button_validate.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 18)
        ui_button_validate.titleLabel?.textColor = .white
        ui_button_validate.layer.cornerRadius = ui_button_validate.frame.height / 2
        ui_button_validate.setTitle("settingsUnblockBT".localized, for: .normal)
        configureWhiteButton(ui_button_validate, withTitle: "settingsUnblockBT".localized)
        
        ui_error_view.populateView(backgroundColor: .white.withAlphaComponent(0.6))
        ui_error_view.hide()
        
        ui_title_empty.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_title_empty.text = "param_empty_blocked_user".localized
        ui_view_empty.isHidden = true
        
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        
        getUsers()
    }
    
    @IBAction func action_validate(_ sender: Any) {
        
        let hasOneCheck = userBlocked.contains(where: {$0.isChecked})
        
        if hasOneCheck {
            let datas = getNameAndIds()
            self.showPopUnBlockUser(username: datas.name, isSingle:datas.ids.count == 1)
        }
        else {
            showError(message: "settingsUnblockUser_error".localized)
        }
    }
    
    func getUsers() {
        MessagingService.getUsersBlocked { users, error in
            if let users = users {
                self.userBlocked.removeAll()
                self.userBlocked.append(contentsOf: users)
                self.ui_tableview.reloadData()
            }
        }
    }
    
    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
      }
      func configureWhiteButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.appOrange.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
      }
    
    func sendUnblockUsers() {
        let datas = getNameAndIds()
        MessagingService.unblockUser(usersID: datas.ids) { error in
            self.showPopValideUnBlock(username: datas.name, isSingle:datas.ids.count == 1)
        }
    }
    
    func showError(message:String) {
        ui_error_view.changeTitleAndImage(title: message)
        ui_error_view.show()
    }
    
    func getNameAndIds() -> (name:String,ids:[Int]) {
        var username = ""
        
        var userIds = [Int]()
        for user in userBlocked {
            if user.isChecked {
                if let _name = user.blockedUser.displayName {
                    let space = username.count == 0 ? "" : ", "
                    username = username + space + _name
                }
                userIds.append(user.blockedUser.uid)
            }
        }
        return (username,userIds)
    }
    
    func showPopUnBlockUser(username:String, isSingle:Bool) {
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "params_unblock_user_pop_bt_unblock".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        let buttonCancel = MJAlertButtonType(title: "params_unblock_user_pop_bt_cancel".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
        
        let desc = String.init(format: "params_unblock_user_pop_message".localized, username)
        let title = isSingle ? "params_unblock_user_pop_title".localized : "params_unblock_users_pop_title".localized
        customAlert.configureAlert(alertTitle: title, message:desc, buttonrightType: buttonAccept, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35)
        
        customAlert.alertTagName = .None
        customAlert.delegate = self
        customAlert.show()
    }
    
    func showPopValideUnBlock(username:String, isSingle:Bool) {
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "params_unblock_user_pop_validate_bt".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        
        let _title = String.init(format: "params_unblock_user_pop_validate_title".localized, username)
        let msg = isSingle ? "params_unblock_user_pop_validate_subtitle".localized : "params_unblock_users_pop_validate_subtitle".localized
        customAlert.configureAlert(alertTitle: _title , message: msg, buttonrightType: buttonAccept, buttonLeftType: nil, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35)
        
        customAlert.alertTagName = .None
        customAlert.show()
        
        getUsers()
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate  -
extension ProfileEditBlockedUsersViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if userBlocked.count == 0 {
            ui_view_empty.isHidden = false
            ui_button_validate.isEnabled = false
            ui_button_validate.alpha = 0.3
        }
        else {
            ui_view_empty.isHidden = true
            ui_button_validate.isEnabled = true
            ui_button_validate.alpha = 1
        }
        return userBlocked.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellInterest", for: indexPath) as! SelectTagCell
        
        let user = userBlocked[indexPath.row]
        
        
        cell.populateCell(title: user.blockedUser.displayName ?? "-" , isChecked: user.isChecked, imageUrl: user.blockedUser.avatarUrl, isUser: true, isAction: false)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isCheck = userBlocked[indexPath.row].isChecked
        
        userBlocked[indexPath.row].isChecked = !isCheck
        
        tableView.reloadData()
    }
}

//MARK: - MJNavBackViewDelegate -
extension ProfileEditBlockedUsersViewController: MJNavBackViewDelegate {
    func didTapEvent() {
        //Nothing yet

    }
    
    func goBack() {
        self.dismiss(animated: true)
    }
}

//MARK: - MJAlertControllerDelegate -
extension ProfileEditBlockedUsersViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag:MJAlertTAG) {}
    
    func validateRightButton(alertTag:MJAlertTAG) {
        if alertTag == .None {
            self.sendUnblockUsers()
        }
    }
    func closePressed(alertTag:MJAlertTAG) {}
    
    func selectedChoice(position: Int) {}
}
