//
//  OTOnboardingPhotoViewController.swift
//  entourage
//
//  Created by Jr on 21/04/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit

class OTOnboardingPhotoViewController: UIViewController {
    
    @IBOutlet weak var ui_constraint_title_top: NSLayoutConstraint!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    @IBOutlet weak var ui_iv_profile: UIImageView!
    
    @IBOutlet weak var ui_bt_take_photo: UIButton!
    @IBOutlet weak var ui_bt_import_gallery: UIButton!
    
    weak var delegate:OnboardV2Delegate? = nil
    
    var pickerViewController:UIImagePickerController? = nil
    var selectedImage:UIImage? = nil
    var currentUserFirstname = ""
    
    @objc var isFromProfile = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isFromProfile {
            ui_constraint_title_top.constant = ui_constraint_title_top.constant + 20
            ui_label_title.text = OTLocalisationService.getLocalizedValue(forKey: "take_photo_title")
            
            ui_label_description.text = OTLocalisationService.getLocalizedValue(forKey: "take_photo_description")
        }
        else {
            ui_label_title.text = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "onboard_photo_title"), currentUserFirstname)
            
            ui_label_description.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_photo_description")
        }
        
        ui_bt_take_photo.setTitle(OTLocalisationService.getLocalizedValue(forKey: "onboard_photo_bt_take_photo")?.uppercased(), for: .normal)
        ui_bt_import_gallery.setTitle(OTLocalisationService.getLocalizedValue(forKey: "onboard_photo_bt_take_gallery")?.uppercased(), for: .normal)
        
        ui_bt_take_photo.layer.cornerRadius = 4
        ui_bt_import_gallery.layer.cornerRadius = 4
        ui_bt_import_gallery.layer.borderColor = UIColor.appOrange()?.cgColor
        ui_bt_import_gallery.layer.borderWidth = 2
        
        ui_iv_profile.layer.cornerRadius = ui_iv_profile.frame.width / 2
    }
    
    //MARK: - Methods -
    func showPicker(sourceType:UIImagePickerControllerSourceType) {
        pickerViewController = UIImagePickerController.init()
        pickerViewController?.modalPresentationStyle = .currentContext
        pickerViewController?.delegate = self
        pickerViewController?.sourceType = sourceType
        self.navigationController?.present(pickerViewController!, animated: true, completion: nil)
    }
    
    func showPhotoResize() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "PictureResizeVC") as? OTPicturePreviewResizeViewController {
            vc.currentImage = self.selectedImage
            vc.delegate = self
            vc.isFromProfile = self.isFromProfile
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
    @IBAction func action_take_photo(_ sender: Any) {
        showPicker(sourceType: .camera)
    }
    
    @IBAction func action_take_from_gallery(_ sender: Any) {
        showPicker(sourceType: .photoLibrary)
    }
}

//MARK: - PickerVC Delegate -
extension OTOnboardingPhotoViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = rotateImage(img: img)
            self.showPhotoResize()
        }
        self.pickerViewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerViewController?.dismiss(animated: true, completion: nil)
    }
}

//MARK: - TakePhoto Delegate -
extension OTOnboardingPhotoViewController:TakePhotoDelegate {
    func updatePhoto(image: UIImage?) {
        self.ui_iv_profile.image = image
        
        if let _image = image {
            delegate?.updateUserPhoto(image: _image)
            delegate?.updateButtonNext(isValid: true)
        }
        else {
            delegate?.updateButtonNext(isValid: false)
        }
    }
}

//MARK: - Protocol -
protocol TakePhotoDelegate:class {
    func updatePhoto(image:UIImage?)
}
