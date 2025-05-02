//
//  ProfileEditPasswordViewController.swift
//  entourage
//
//  Created by - on 05/01/2023.
//

import UIKit
import IQKeyboardManagerSwift
import SimpleKeychain
import IHProgressHUD

class ProfileEditPasswordViewController: UIViewController {
    
    @IBOutlet weak var ui_error_view: MJErrorInputView!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    
    @IBOutlet weak var ui_title_old: UILabel!
    @IBOutlet weak var ui_title_new: UILabel!
    @IBOutlet weak var ui_title_confirm: UILabel!
    
    @IBOutlet weak var ui_tf_old: UITextField!
    @IBOutlet weak var ui_tf_new: UITextField!
    @IBOutlet weak var ui_tf_confirm: UITextField!
    
    @IBOutlet weak var btn_validate: UIButton!
    
    let MIN_PASSWORD_LENGTH = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_top_view.populateView(title: "param_change_pwd_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self)
        
        
        self.modalPresentationStyle = .fullScreen
        
        ui_title_old.text = "oldCode".localized
        ui_title_new.text = "newCode".localized
        ui_title_confirm.text = "confirmCode".localized
        
        ui_tf_old.placeholder = "placeholder_changePwd".localized
        ui_tf_new.placeholder = "placeholder_changePwd".localized
        ui_tf_confirm.placeholder = "placeholder_changePwd".localized
        
        ui_tf_old.delegate = self
        ui_tf_new.delegate = self
        ui_tf_confirm.delegate = self
        
        ui_title_old.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularOrange(size: 13))
        ui_title_new.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularOrange(size: 13))
        //ui_title_confirm.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularOrange(size: 13))
        
        ui_tf_old.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 13))
        ui_tf_new.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 13))
        //ui_tf_confirm.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 13))
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        configureOrangeButton(btn_validate, withTitle: "validate".localized)

        ui_error_view.populateView(backgroundColor: .white.withAlphaComponent(0.6))
        ui_error_view.hide()
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
    
    deinit {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    @IBAction func action_tap(_ sender: Any) {
        resignResponder()
    }
    private func resignResponder() {
        ui_tf_old.resignFirstResponder()
        ui_tf_new.resignFirstResponder()
        ui_tf_confirm.resignFirstResponder()
    }
    
    @IBAction func action_validate(_ sender: Any) {
        resignResponder()
        validate()
    }
    
    private func validate() {
        let oldPwd = ui_tf_old.text
        let newPwd = ui_tf_new.text
        let confirmPwd = ui_tf_confirm.text
        let currentPwd = A0SimpleKeychain().string(forKey: kKeychainPassword)
        
        if oldPwd != currentPwd {
            showError(message: "pwdError".localized)
            return
        }
        
        if newPwd?.count ?? 0 < MIN_PASSWORD_LENGTH {
            showError(message: "pwdShort".localized)
            return
        }
        
        if newPwd != confirmPwd {
            showError(message: "pwdDiff".localized)
            return
        }
        
        UserService.updateUserPassword(pwd: newPwd!) { user, error in
            Logger.print("***** Mot reurn \(user) - Error  :\(error)")
            if error == nil {
                IHProgressHUD.showSuccesswithStatus("pwdUpdated".localized)
            }
            else {
                IHProgressHUD.showError(withStatus: "pwdUpdatedErr".localized)
            }
            
            DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now() + 0.5, execute: {
                self.goBack()
            })
            
            DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now() + 1.5, execute: {
                IHProgressHUD.dismiss()
            })
        }
    }
    
    func showError(message:String) {
        ui_error_view.changeTitleAndImage(title: message)
        ui_error_view.show()
    }
}
//MARK: - UITextFieldDelegate -
extension ProfileEditPasswordViewController:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < 10
    }
}

//MARK: - MJNavBackViewDelegate -
extension ProfileEditPasswordViewController: MJNavBackViewDelegate {
    func didTapEvent() {
        //Nothing yet
    }
    
    func goBack() {
        self.dismiss(animated: true)
    }
}
