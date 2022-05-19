//
//  NeighborhoodPostAddPhotoViewController.swift
//  entourage
//
//  Created by Jerome on 18/05/2022.
//

import UIKit

class NeighborhoodPostAddPhotoViewController: BasePopViewController {
    
    @IBOutlet weak var ui_iv_post: UIImageView!
    @IBOutlet weak var ui_image_placeholder: UIImageView!
    @IBOutlet weak var ui_bt_take_photo: UIButton!
    @IBOutlet weak var ui_bt_import_gallery: UIButton!
    
    var pickerViewController:UIImagePickerController? = nil
    var selectedImage:UIImage? = nil
    var parentDelegate:TakePhotoDelegate? = nil
    
    let cornerRadiusImage:CGFloat = 14
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_top_view.populateView(title: "neighborhood_add_post_title_image".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
        
        ui_bt_take_photo.titleLabel?.font = ApplicationTheme.getFontBoutonBlanc().font
        ui_bt_take_photo.setTitleColor(.white, for: .normal)
        ui_bt_take_photo.tintColor = .white
        ui_bt_take_photo.backgroundColor = .appOrangeLight
        ui_bt_take_photo.layer.cornerRadius = ui_bt_take_photo.frame.height / 2
        
        ui_bt_import_gallery.titleLabel?.font = ApplicationTheme.getFontBoutonOrange().font
        ui_bt_import_gallery.setTitleColor(.white, for: .normal)
        ui_bt_import_gallery.tintColor = .white
        ui_bt_import_gallery.backgroundColor = .appOrange
        ui_bt_import_gallery.layer.cornerRadius = ui_bt_import_gallery.frame.height / 2
        
        ui_bt_take_photo.setTitle("take_photo".localized, for: .normal)
        ui_bt_import_gallery.setTitle("take_gallery".localized, for: .normal)
        
        ui_iv_post.layer.cornerRadius = cornerRadiusImage
        ui_iv_post.layer.borderWidth = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hideTransparentNavigationBar()
    }
    
    //MARK: - Methods -
    
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
        if let vc = storyboard?.instantiateViewController(withIdentifier: "PictureResizeVC") as? NeighborhoodPostPicturePreviewResizeViewController {
            vc.currentImage = self.selectedImage
            vc.delegate = self
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
extension NeighborhoodPostAddPhotoViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
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
extension NeighborhoodPostAddPhotoViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

//MARK: - TakePhoto Delegate -
extension NeighborhoodPostAddPhotoViewController:TakePhotoDelegate {
    func updatePhoto(image: UIImage?) {
        self.parentDelegate?.updatePhoto(image: image)
        goBack()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
