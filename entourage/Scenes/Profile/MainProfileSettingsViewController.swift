//
//  HomeMainProfileViewController.swift
//  entourage
//
//  Created by Jerome on 08/03/2022.
//

import UIKit
import SDWebImage

class MainProfileSettingsViewController: UIViewController {
    
    @IBOutlet weak var ui_view_button_edit_profile: UIView!
    @IBOutlet weak var ui_label_edit: UILabel!
    
    @IBOutlet weak var ui_constraint_top_image: NSLayoutConstraint!
    
    @IBOutlet weak var ui_container: UIView!
    
    //MARK: - view profile -
    let radius_main_view:CGFloat = 35
    let radius_button_edit:CGFloat = 23
    
    @IBOutlet weak var ui_label_profile: UILabel!
    @IBOutlet weak var ui_view_indicator_profile: UIView!
    @IBOutlet weak var ui_label_params: UILabel!
    @IBOutlet weak var ui_view_indicator_params: UIView!
    
    var isProfileSelected = true
    
    @IBOutlet weak var ui_view_top_white: UIView!
    @IBOutlet weak var ui_view_img_profile: UIView!
    @IBOutlet weak var ui_image_user: UIImageView!
    
    @IBOutlet weak var ui_username: UILabel!
    @IBOutlet weak var ui_view_nav: MJNavBackView!
    var currentUser:User!
    
    var profileVC:UIViewController? = nil
    var paramsVC:UIViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_view_nav.populateCustom(title:nil, imageName: "back_button_white", backgroundColor: .clear, delegate: self, showSeparator: false,marginLeftButton: 24)
        
        setupVCs()
        setupTopViews()
        
        currentUser = UserDefaults.currentUser
        
        changeTabSelection()
        setupPhotoUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUser), name: NSNotification.Name(kNotificationProfilePictureUpdated), object: nil)
        updateUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hideTransparentNavigationBar()
        
        loadUser()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Custom UI -
    func setupTopViews() {
        
        ui_username.textColor = ApplicationTheme.getFontCourantBoldBlanc().color
        ui_username.font = ApplicationTheme.getFontCourantBoldBlanc().font
        
        ui_label_edit.text = "modify".localized
        ui_label_edit.font = ApplicationTheme.getFontCourantBoldOrangeClair().font
        ui_label_edit.textColor = ApplicationTheme.getFontCourantBoldOrange().color
        ui_view_button_edit_profile.layer.cornerRadius = radius_button_edit
        ui_view_button_edit_profile.backgroundColor = .white
        
        ui_label_profile.font = ApplicationTheme.getFontCourantBoldOrange().font
        ui_label_profile.textColor = ApplicationTheme.getFontCourantBoldOrange().color
        
        ui_label_profile.text = "myProfileButton".localized
        ui_label_params.text = "myParamsButton".localized
    }
    
    func setupPhotoUI() {
        ui_image_user.layer.cornerRadius = ui_image_user.frame.height / 2
        
        ui_view_img_profile.layer.cornerRadius = ui_image_user.frame.height / 2
        ui_view_img_profile.layer.borderColor = UIColor.white.cgColor
        ui_view_img_profile.layer.borderWidth = 1
        
        ui_view_img_profile.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        ui_view_img_profile.layer.shadowOpacity = 1
        ui_view_img_profile.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        ui_view_img_profile.layer.shadowRadius = 10
        
        ui_view_img_profile.layer.rasterizationScale = UIScreen.main.scale
        ui_view_img_profile.layer.shouldRasterize = true
        
        ui_view_top_white.clipsToBounds = true
        ui_view_top_white.addRadiusTopOnly(radius: radius_main_view)
    }
    
    //MARK: - Network User -
    func loadUser() {
        guard let uuid = currentUser?.uuid else { return }
        UserService.getDetailsForUser(userId: uuid) { [weak self] user, error in
            if let _user = user {
                self?.currentUser = _user
                UserDefaults.currentUser = _user
                DispatchQueue.main.async {
                    self?.updateUser()
                }
            }
        }
    }
    
    @objc func updateUser() {
        if let user = UserDefaults.currentUser,let _url = user.avatarURL, let mainUrl = URL(string: _url) {
            ui_image_user.sd_setImage(with: mainUrl, placeholderImage: UIImage.init(named: "placeholder_user"))
        }
        //To force update profile mainuserprofileVC when show main page
        (profileVC as? MainUserProfileViewController)?.updateUser()
        ui_username.text = currentUser.displayName
    }
    
    //MARK: - IBActions -
    @IBAction func action_show_edit_profile(_ sender: Any) {
        let sb = UIStoryboard.init(name: "ProfileParams", bundle: nil)
        let navVC = sb.instantiateViewController(withIdentifier: "editProfileMainNav")
        self.navigationController?.present(navVC, animated: true)
    }
    
    @IBAction func action_profile(_ sender: Any) {
        isProfileSelected = true
        changeTabSelection()
    }
    
    @IBAction func action_params(_ sender: Any) {
        isProfileSelected = false
        changeTabSelection()
    }
    
    //MARK: - tab bar
    func changeTabSelection() {
        if isProfileSelected {
            ui_label_profile.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
            ui_label_params.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrangeClair())
            ui_view_indicator_profile.isHidden = false
            ui_view_indicator_params.isHidden = true
        }
        else {
            ui_label_profile.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrangeClair())
            ui_label_params.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
            ui_view_indicator_profile.isHidden = true
            ui_view_indicator_params.isHidden = false
        }
        changeVC()
    }
    
    func setupVCs() {
        profileVC = UIStoryboard.init(name: "ProfileParams", bundle: nil).instantiateViewController(withIdentifier: "mainUserProfileVC") as? MainUserProfileViewController
        
        paramsVC = UIStoryboard.init(name: "ProfileParams", bundle: nil).instantiateViewController(withIdentifier: "mainParamVC")
    }
    
    func changeVC() {
        if isProfileSelected {
            if let _ = paramsVC {
                paramsVC?.willMove(toParent: nil)
                paramsVC?.view.removeFromSuperview()
                paramsVC?.removeFromParent()
            }
            
            if let _ = profileVC {
                addChild(profileVC!)
                (profileVC as? MainUserProfileViewController)?.updateVC()
                profileVC?.view.frame.size = self.ui_container.frame.size
                ui_container.addSubview(profileVC!.view)
                profileVC!.didMove(toParent: self)
            }
        }
        else {
            if let _ = profileVC {
                profileVC?.willMove(toParent: nil)
                profileVC?.view.removeFromSuperview()
                profileVC?.removeFromParent()
            }
            
            if let _ = paramsVC {
                addChild(paramsVC!)
                //(groupsVC as? OTMyEntourageMessagesViewController)?.loadDatas()
                paramsVC?.view.frame.size = self.ui_container.frame.size
                ui_container.addSubview(paramsVC!.view)
                paramsVC!.didMove(toParent: self)
            }
        }
    }
}


//MARK: - MJNavBackViewDelegate -
extension MainProfileSettingsViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}
