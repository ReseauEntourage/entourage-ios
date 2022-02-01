//
//  OTPicturePreviewResizeViewController.swift
//  entourage
//
//  Created by Jr on 27/04/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import SVProgressHUD

class OTPicturePreviewResizeViewController: UIViewController {
    
    @IBOutlet weak var ui_bt_validate: UIButton!
    @IBOutlet weak var ui_bt_cancel: UIButton!
    @IBOutlet weak var ui_bt_valide_from_profile: UIButton!
    @IBOutlet weak var ui_scrollview: UIScrollView!
    @IBOutlet weak var ui_iv_preview: UIImageView!
    
    var currentImage:UIImage? = nil
    weak var delegate:TakePhotoDelegate? = nil
    let MaxImageSize:CGFloat = 300
    
    var isFromProfile = false
    var isFromDeepLink = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentImage = currentImage?.toSquare()
        self.ui_iv_preview.image = self.currentImage
        self.ui_scrollview.maximumZoomScale = 10
        
        if isFromProfile {
            ui_bt_cancel.isHidden = true
            ui_bt_validate.isHidden = true
            ui_bt_valide_from_profile.isHidden = false
        }
        else {
            ui_bt_cancel.isHidden = false
            ui_bt_validate.isHidden = false
            ui_bt_valide_from_profile.isHidden = true
        }
    }
    
    //MARK: - Methods Images -
    func processImage() -> UIImage? {
        if let _finalImage = self.cropVisibleArea() {
            return _finalImage.resize(to: CGSize(width: MaxImageSize, height: MaxImageSize))
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
            SVProgressHUD.show()
            OTLogger.logEvent(Action_Profile_Photo_Submit)
            OTPictureUploadS3Service.prepareUploadWith(image: _image,completion: {isOk in
                if isOk {
                    self.popToProfile()
                }
                else {
                    SVProgressHUD.showError(withStatus: OTLocalisationService.getLocalizedValue(forKey: "user_photo_change_error"))
                }
            })
            return;
        }
    }
    
    func popToProfile() {
        SVProgressHUD.dismiss()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationProfilePictureUpdated), object: self)
        if let _navController = self.navigationController {
            if self.isFromDeepLink {
                self.navigationController?.dismiss(animated: true, completion: nil)
                return
            }
            for vc in _navController.viewControllers {
                if vc.isKind(of: OTUserEditViewController.classForCoder()) {
                    self.navigationController?.popToViewController(vc, animated: true)
                    break
                }
            }
        }
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
    
    @IBAction func action_cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - UIScrollViewDelegate -
extension OTPicturePreviewResizeViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.ui_iv_preview
    }
}
