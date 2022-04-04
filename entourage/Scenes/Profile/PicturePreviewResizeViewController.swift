//
//  OTPicturePreviewResizeViewController.swift
//  entourage
//
//  Created by Jr on 27/04/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import IHProgressHUD

class PicturePreviewResizeViewController: BasePopViewController {
    
    @IBOutlet weak var ui_bt_valide_from_profile: UIButton!
    
    @IBOutlet weak var ui_label_description: UILabel!
    @IBOutlet weak var ui_bt_validate: UIButton!
    @IBOutlet weak var ui_bt_cancel: UIButton!
    
    @IBOutlet weak var ui_scrollview: UIScrollView!
    @IBOutlet weak var ui_iv_preview: UIImageView!
    
    var currentImage:UIImage? = nil
    weak var delegate:TakePhotoDelegate? = nil
    let MaxImageSize:CGFloat = 300
    
    var isFromProfile = false
    var isFromDeepLink = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_label_description.font = ApplicationTheme.getFontTextRegular().font
        ui_label_description.textColor = ApplicationTheme.getFontTextRegular().color
        ui_label_description.text = "description_move_photo".localized
        
        ui_bt_validate.setTitle("validate".localized, for: .normal)
        ui_bt_cancel.setTitle("cancel".localized, for: .normal)
        ui_bt_valide_from_profile.setTitle("validate".localized, for: .normal)
        
        ui_top_view.populateView(title: "", titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self)
        
        self.currentImage = currentImage?.toSquare()
        self.ui_iv_preview.image = self.currentImage
        self.ui_scrollview.maximumZoomScale = 10
        
        if isFromProfile {
            ui_bt_cancel.isHidden = true
            ui_bt_validate.isHidden = true
            ui_bt_valide_from_profile.isHidden = false
            ui_top_view.isHidden = false
            
            ui_bt_valide_from_profile.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 18)
            ui_bt_valide_from_profile.setTitleColor(.white, for: .normal)
            ui_bt_valide_from_profile.tintColor = .white
            ui_bt_valide_from_profile.backgroundColor = .appOrange
            ui_bt_valide_from_profile.layer.cornerRadius = ui_bt_valide_from_profile.frame.height / 2
            
        }
        else {
            ui_bt_cancel.isHidden = false
            ui_bt_validate.isHidden = false
            ui_bt_valide_from_profile.isHidden = true
            ui_top_view.isHidden = true
        }
    }
    
    //MARK: - Methods Images -
    func processImage() -> UIImage? {
        if let _finalImage = self.cropVisibleArea() {
            return _finalImage.resizeTo(size: CGSize(width: MaxImageSize, height: MaxImageSize))
        }
        return nil
    }
    
    func cropVisibleArea() -> UIImage? {
        guard let _currentImg = self.currentImage else {
            return nil
        }
        var visibleRect = CGRect.zero
        let scale = 1.0 / self.ui_scrollview.zoomScale
        visibleRect.origin.x = self.ui_scrollview.contentOffset.x / self.ui_scrollview.contentSize.width * _currentImg.size.width;
        visibleRect.origin.y = self.ui_scrollview.contentOffset.y / self.ui_scrollview.contentSize.height * _currentImg.size.height;
        visibleRect.size.width = _currentImg.size.width * scale;
        visibleRect.size.height = _currentImg.size.height * scale;
        if let image = self.imageByCropping(image: _currentImg, toCroppedArea: visibleRect) {
            return image
        }
        return nil
    }
    
    func imageByCropping(image _image: UIImage, toCroppedArea:CGRect) -> UIImage? {
        if let cropImgRef = _image.cgImage?.cropping(to: toCroppedArea) {
            
            let _imgCropped = UIImage.init(cgImage: cropImgRef)
            
            return _imgCropped
        }
        return nil
    }
    
    //MARK: - Network -
    func updateUserPhoto() {
        if let _image = self.processImage() {
            IHProgressHUD.show()
            //  OTLogger.logEvent(Action_Profile_Photo_Submit)
            PictureUploadS3Service.prepareUploadWith(image: _image,completion: { [weak self] isOk in
                if isOk, let self = self {
                    self.popToProfile()
                    return
                }
                IHProgressHUD.showError(withStatus: "user_photo_change_error".localized)
            })
            return
        }
    }
    
    func popToProfile() {
        IHProgressHUD.dismiss()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationProfilePictureUpdated), object: self)
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - IBActions -
    @IBAction func action_validate(_ sender: Any) {
        if isFromProfile {
            self.updateUserPhoto()
        }
        else {
            delegate?.updatePhoto(image: self.processImage())
            self.navigationController?.popViewController(animated: true)
        }
    }
}

//MARK: - UIScrollViewDelegate -
extension PicturePreviewResizeViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.ui_iv_preview
    }
}

//MARK: - MJNavBackViewDelegate -
extension PicturePreviewResizeViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
