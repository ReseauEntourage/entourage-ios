//
//  OTOnboardingPhotoViewController.swift
//  entourage
//
//  Created by Jr on 21/04/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import AVFoundation

class UserPhotoAddViewController: BasePopViewController {
        
    @IBOutlet weak var ui_constraint_title_top: NSLayoutConstraint!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    @IBOutlet weak var ui_iv_profile: UIImageView!
    //special smalltalk
    @IBOutlet weak var ui_progress_view: UIProgressView!
    @IBOutlet weak var ui_btn_smalltalk_continu: UIButton!
    @IBOutlet weak var ui_btn_smalltalk_previous: UIButton!
    
    @IBOutlet weak var ui_bt_take_photo: UIButton!
    @IBOutlet weak var ui_bt_import_gallery: UIButton!
    
    var pickerViewController:UIImagePickerController? = nil
    var selectedImage:UIImage? = nil
    var currentUserFirstname = ""
    var pictureSettingDelegate:ImageReUpLoadDelegate?
    
    var isFromProfile = true
    var isFromDeepLink = false
    var isSmallTalkMode = false
    var userRequest:UserSmallTalkRequest? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_progress_view.progressTintColor = UIColor(red: 0.67, green: 0.87, blue: 0.64, alpha: 1.0) // proche de #ACDFA3
        ui_progress_view.trackTintColor = UIColor(white: 0.9, alpha: 1.0)
        
        configureOrangeButton(ui_btn_smalltalk_continu, withTitle: "action_create_close_button".localized)
        configureOrangeButton(ui_bt_take_photo, withTitle: "take_photo".localized)
        configureWhiteButton(ui_btn_smalltalk_previous, withTitle: "previous".localized)
        configureWhiteButton(ui_bt_import_gallery, withTitle: "take_gallery".localized)
        
        ui_btn_smalltalk_continu.addTarget(self, action: #selector(onContinueClick), for: .touchUpInside)
        ui_btn_smalltalk_previous.addTarget(self, action: #selector(onPreviousClick), for: .touchUpInside)
        
        if (!isSmallTalkMode) {
            ui_progress_view.isHidden = true
            ui_btn_smalltalk_continu.isHidden = true
            ui_btn_smalltalk_previous.isHidden = true
        }else{
            ui_top_view.isHidden = true
            ui_constraint_title_top.constant = 0

        }
        if isFromProfile {
            AnalyticsLoggerManager.logEvent(name: View_Profile_Choose_Photo)
            ui_constraint_title_top.constant = 0
            ui_label_title.isHidden = true
            ui_label_title.text = ""
            
            ui_label_description.text = "take_photo_description".localized
            let cancelBt = UIBarButtonItem(title: "cancel".localized, style: .plain, target: self, action: #selector(close))
            self.navigationItem.setLeftBarButton(cancelBt, animated: true)
            
            ui_top_view.populateView(title: "take_photo_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
            
            ui_bt_take_photo.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 18)
            ui_bt_take_photo.setTitleColor(.white, for: .normal)
            ui_bt_take_photo.tintColor = .white
            ui_bt_take_photo.backgroundColor = .appOrangeLight
            ui_bt_take_photo.layer.cornerRadius = ui_bt_take_photo.frame.height / 2
            
            ui_bt_import_gallery.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 18)
            ui_bt_import_gallery.setTitleColor(.white, for: .normal)
            ui_bt_import_gallery.tintColor = .white
            ui_bt_import_gallery.backgroundColor = .appOrange
            ui_bt_import_gallery.layer.cornerRadius = ui_bt_import_gallery.frame.height / 2
            
            if let user = UserDefaults.currentUser, let _url = user.avatarURL, let mainUrl = URL(string: _url) {
                ui_iv_profile.sd_setImage(with: mainUrl, placeholderImage: UIImage.init(named: "placeholder_user"))
            }
            else {
                ui_iv_profile.image = UIImage.init(named: "placeholder_user")
            }
        }
        else {
            //  OTLogger.logEvent(View_Onboarding_Choose_Photo)
            ui_label_title.text = String.init(format: "onboard_photo_title".localized, currentUserFirstname)
            
            ui_label_description.text = "onboard_photo_description".localized
            
            ui_bt_take_photo.layer.cornerRadius = 4
            ui_bt_import_gallery.layer.cornerRadius = 4
            ui_bt_import_gallery.layer.borderColor = UIColor.appOrange.cgColor
            ui_bt_import_gallery.layer.borderWidth = 2
        }
        
        ui_label_description.font = ApplicationTheme.getFontCourantRegularNoir().font
        ui_label_description.textColor = ApplicationTheme.getFontCourantRegularNoir().color
        
        ui_bt_take_photo.setTitle("take_photo".localized, for: .normal)
        ui_bt_import_gallery.setTitle("take_gallery".localized, for: .normal)
        configureOrangeButton(ui_bt_import_gallery, withTitle: "take_gallery".localized)
        configureWhiteButton(ui_bt_take_photo, withTitle: "take_photo".localized)
        
        ui_iv_profile.layer.cornerRadius = ui_iv_profile.frame.width / 2
        ui_iv_profile.layer.borderColor = UIColor.lightGray.cgColor
        ui_iv_profile.layer.borderWidth = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hideTransparentNavigationBar()
    }
    
    @objc func onContinueClick() {
        guard let userRequest = self.userRequest else {
            let alert = UIAlertController(title: "Erreur", message: "Identifiant introuvable", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }

        let sb = UIStoryboard(name: "SmallTalk", bundle: nil)
        if let nextVC = sb.instantiateViewController(withIdentifier: "SmallTalkSearchingViewController") as? SmallTalkSearchingViewController {
            nextVC.configure(with: userRequest)
            nextVC.modalPresentationStyle = .fullScreen

            // ✅ on remplace totalement la navigation
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = nextVC
                window.makeKeyAndVisible()
            } else {
                self.present(nextVC, animated: true)
            }
        }
    }

    
    @objc func onPreviousClick() {
        if isSmallTalkMode {
            self.dismiss(animated: true) // on ferme seulement cette vue
        } else {
            navigationController?.popViewController(animated: true)
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
    
    //MARK: - Methods -
    
    @objc func close() {
        self.dismiss(animated: true)

    }
    
    func showPicker(sourceType:UIImagePickerController.SourceType) {
        pickerViewController = UIImagePickerController.init()
        pickerViewController?.modalPresentationStyle = .currentContext
        pickerViewController?.delegate = self
        pickerViewController?.sourceType = sourceType
        pickerViewController?.navigationBar.tintColor = .appOrange
        pickerViewController?.navigationBar.backgroundColor = .white
        self.navigationController?.present(pickerViewController!, animated: true, completion: nil)
    }
    
    func showPhotoResize() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "PictureResizeVC") as? PicturePreviewResizeViewController {
            vc.pictureSettingDelegate = self.pictureSettingDelegate
            vc.currentImage = self.selectedImage
            vc.isSmallTalkMode = self.isSmallTalkMode
            vc.delegate = self
            vc.isFromProfile = self.isFromProfile
            vc.isFromDeepLink = self.isFromDeepLink
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func rotateImage(img:UIImage) -> UIImage? {
        if (img.imageOrientation == .up) {
            return img
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        img.draw(in: CGRect.init(x: 0, y: 0, width: img.size.width, height: img.size.height))
        let imgNew = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return imgNew
    }
    
    //MARK: - IBActions -
    @IBAction func action_close(_ sender: Any) {
        close()
    }
    
    @IBAction func action_take_photo(_ sender: Any) {
        if isFromProfile {
            AnalyticsLoggerManager.logEvent(name: Action_Profile_Take_Photo)
        }
        checkCameraAccess()
    }
    
    func checkCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.presentCameraSettings()
            }
        case .authorized:
            DispatchQueue.main.async {
                self.showPicker(sourceType: .camera)
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                DispatchQueue.main.async {
                    if success {
                        self.showPicker(sourceType: .camera)
                    } else {
                        self.presentCameraSettings()
                    }
                }
            }
        @unknown default:
            break
        }
    }

    
    func presentCameraSettings() {
        
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "cancel".localized, titleStyle:ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
        let buttonValidate = MJAlertButtonType(title: "toSettings".localized, titleStyle:ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        alertVC.configureAlert(alertTitle: "errorSettings".localized, message: "authCameraSettings".localized, buttonrightType: buttonValidate, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true)
        
        alertVC.delegate = self
        alertVC.show()
    }
    
    @IBAction func action_take_from_gallery(_ sender: Any) {
        if isFromProfile {
            AnalyticsLoggerManager.logEvent(name: Action_Profile_Upload_Photo)
        }
        
        showPicker(sourceType: .photoLibrary)
    }
}

//MARK: - MJAlertControllerDelegate -
extension UserPhotoAddViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag: MJAlertTAG) {

    }
    func validateRightButton(alertTag: MJAlertTAG) {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
   

//MARK: - PickerVC Delegate -
extension UserPhotoAddViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        
        if let img = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            selectedImage = rotateImage(img: img)
            self.showPhotoResize()
        }
        self.pickerViewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerViewController?.dismiss(animated: true, completion: nil)
    }
}

//MARK: - MJNavBackViewDelegate -
extension UserPhotoAddViewController: MJNavBackViewDelegate {
    func goBack() {
        self.close()
    }
    func didTapEvent() {
        //Nothing yet
    }
}

//MARK: - TakePhoto Delegate -
extension UserPhotoAddViewController:TakePhotoDelegate {
    func updatePhoto(image: UIImage?) {
        self.ui_iv_profile.image = image
    }
}

//MARK: - Protocol -
protocol TakePhotoDelegate:AnyObject {
    func updatePhoto(image:UIImage?)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
