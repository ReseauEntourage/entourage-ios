//
//  NeighborhoodPostAddViewController.swift
//  entourage
//
//  Created by Jerome on 19/05/2022.
//

import UIKit
import IHProgressHUD


class NeighborhoodPostAddViewController: UIViewController {
    
    @IBOutlet weak var ui_top_view: MJNavBackView!
    
    @IBOutlet weak var ui_lb_message: UILabel!
    @IBOutlet weak var ui_lb_message_dsc: UILabel!
    @IBOutlet weak var ui_lb_photo: UILabel!
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_image_placeholder: UIImageView!
    @IBOutlet weak var ui_lb_photo_dsc: UILabel!
    
    @IBOutlet weak var ui_view_button_validate: UIView!
    
    
    @IBOutlet weak var ui_iv_bt_add_remove: UIImageView!
    @IBOutlet weak var ui_title_button_validate: UILabel!
    @IBOutlet weak var ui_tv_message: MJTextViewPlaceholder!
    
    @IBOutlet weak var ui_tv_error: UILabel!
    @IBOutlet weak var ui_view_error: UIView!
    var currentImage:UIImage? = nil
    
    let cornerRadiusImage:CGFloat = 14
    
    var isValid = false
    
    var neighborhoodId:Int = 0
    var eventId:Int = 0
    
    var isNeighborhood = true
    
    var isLoading = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ui_top_view.populateView(title: "neighborhood_add_post_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: false)
        ui_lb_message.text = "neighborhood_add_post_message_title".localized
        ui_lb_message_dsc.text = "neighborhood_add_post_message_subtitle".localized
        
        ui_lb_photo.text = "neighborhood_add_post_image_title".localized
        ui_lb_photo_dsc.text = "neighborhood_add_post_image_subtitle".localized
        ui_title_button_validate.text = "neighborhood_add_post_send_button".localized
        
        ui_tv_message.placeholderText = "neighborhood_add_post_message_placeholder".localized
        ui_tv_message.placeholderColor = .lightGray
        
        let buttonDone = UIBarButtonItem(title: "validate".localized, style: .plain, target: self, action: #selector(closeKb))
        let _width = UIApplication.shared.delegate?.window??.frame.width ?? view.frame.size.width
        ui_tv_message.addToolBar(width: _width, buttonValidate: buttonDone)
        
        ui_lb_message.setupFontAndColor(style: ApplicationTheme.getFontH2Noir())
        ui_lb_photo.setupFontAndColor(style: ApplicationTheme.getFontH2Noir())
        ui_lb_message_dsc.setupFontAndColor(style: ApplicationTheme.getFontLegend())
        ui_lb_photo_dsc.setupFontAndColor(style: ApplicationTheme.getFontLegend())
        
        ui_title_button_validate.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
        ui_view_button_validate.layer.cornerRadius = ui_view_button_validate.frame.height / 2
        
        ui_image.layer.cornerRadius = cornerRadiusImage
        ui_view_error.isHidden = true
        ui_tv_error.text = "neighborhood_add_post_error".localized
        ui_tv_error.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoRegularItalic(size: 11), color: .rougeErreur))
        showButton(isAdd: true)
        changeButtonShare()
        
        if isNeighborhood {
            AnalyticsLoggerManager.logEvent(name: View_GroupFeed_NewPost_Screen)
        }
    }
    
    @objc func closeKb() {
        let _ = ui_tv_message.resignFirstResponder()
        changeButtonShare()
    }
    
    deinit {
        Logger.print("***** deinit VC")
    }
    
    func showButton(isAdd:Bool) {
        let imgName = isAdd ? "ic_neighb_bt_plus" : "ic_button_close_white_round"
        ui_iv_bt_add_remove.image = UIImage.init(named: imgName)
    }
    
    func changeButtonShare() {
        if currentImage != nil || !(ui_tv_message.text?.isEmpty ?? true) {
            ui_view_button_validate.backgroundColor = .appOrange
            isValid = true
        }
        else {
            isValid = false
            ui_view_button_validate.backgroundColor = .appOrangeLight_50
        }
    }
    
    @IBAction func action_add_or_clear(_ sender: Any) {
        if currentImage != nil {
            currentImage = nil
            self.ui_image.image = nil
            showButton(isAdd: true)
            self.ui_image.backgroundColor = .appBeige
            self.ui_image_placeholder.isHidden = false
            changeButtonShare()
        }
        else {
            if isNeighborhood {
                AnalyticsLoggerManager.logEvent(name: Action_GroupFeed_NewPost_AddPic)
            }
            
            if let navvc = storyboard?.instantiateViewController(withIdentifier: "addPhotoNav") as? UINavigationController, let vc = navvc.topViewController as? NeighborhoodPostAddPhotoViewController {
                vc.parentDelegate = self
                self.present(navvc, animated: true)
            }
        }
        
    }
    
    
    @IBAction func action_send(_ sender: Any) {
        if !isValid || isLoading { return }
        if currentImage == nil {
            sendMessageOnly()
        }
        else {
            sendImageText()
        }
        if isNeighborhood {
            AnalyticsLoggerManager.logEvent(name: Action_GroupFeed_NewPost_Validate)
        }
    }
    
    //MARK: - Network -
    func sendMessageOnly() {
        isLoading = true
        IHProgressHUD.show()
        let message = ui_tv_message.text!
        if isNeighborhood {
            NeighborhoodService.createPostMessage(groupId: neighborhoodId, message: message) { error in
                self.isLoading = false
                
                if error != nil {
                    self.ui_view_error.isHidden = false
                }
                else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNeighborhoodUpdate), object: nil)
                    self.goBack()
                }
            }
        }
        else {
            EventService.createPostMessage(eventId: eventId, message: message) { error in
                self.isLoading = false
                
                if error != nil {
                    self.ui_view_error.isHidden = false
                }
                else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationEventUpdate), object: nil)
                    self.goBack()
                }
            }
        }
    }
    
    func sendImageText() {
        self.isLoading = true
        IHProgressHUD.show()
        if isNeighborhood {
            NeighborhoodUploadPictureService.prepareUploadWith(neighborhoodId: neighborhoodId, image: currentImage!, message: ui_tv_message.text) { isOk in
                self.isLoading = false
                
                if !isOk {
                    self.ui_view_error.isHidden = false
                }
                else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNeighborhoodUpdate), object: nil)
                    self.goBack()
                }
            }
        }
        else {
            EventUploadPictureService.prepareUploadWith(eventId: eventId, image: currentImage!, message: ui_tv_message.text) { isOk in
                self.isLoading = false
                
                if !isOk {
                    self.ui_view_error.isHidden = false
                }
                else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationEventUpdate), object: nil)
                    self.goBack()
                }
            }
        }
    }
}

//MARK: - TakePhotoDelegate -
extension NeighborhoodPostAddViewController: TakePhotoDelegate {
    func updatePhoto(image: UIImage?) {
        if image == nil {
            self.ui_image.backgroundColor = .appBeige
            self.ui_image_placeholder.isHidden = false
        }
        else {
            self.ui_image.backgroundColor = .clear
            self.ui_image_placeholder.isHidden = true
        }
        self.currentImage = image
        self.ui_image.image = self.currentImage
        self.showButton(isAdd: image == nil)
        
        changeButtonShare()
    }
}

//MARK: - MJNavBackViewDelegate -
extension NeighborhoodPostAddViewController: MJNavBackViewDelegate {
    func goBack() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            IHProgressHUD.dismiss()
            self.dismiss(animated: true)
        }
    }
}
