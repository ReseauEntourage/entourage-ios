//
//  NeighborhoodPostPicturePreviewResizeViewController.swift
//  entourage
//
//  Created by Jerome on 19/05/2022.
//

import UIKit

class NeighborhoodPostPicturePreviewResizeViewController: BasePopViewController {
    
    @IBOutlet weak var ui_view_crop: UIView!
    @IBOutlet weak var ui_bt_valide: UIButton!
    @IBOutlet weak var ui_bt_cancel: UIButton!
    
    @IBOutlet weak var ui_label_description: UILabel!
    
    @IBOutlet weak var ui_scrollview: UIScrollView!
    @IBOutlet weak var ui_iv_preview: UIImageView!
    
    var currentImage:UIImage? = nil
    weak var delegate:TakePhotoDelegate? = nil
    let maxImageWidhtSize:CGFloat = 326 * 3
    let maxImageHeightSize:CGFloat = 184 * 3
    
    let cornerRadiusImage:CGFloat = 14
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_label_description.font = ApplicationTheme.getFontCourantRegularNoir().font
        ui_label_description.textColor = ApplicationTheme.getFontCourantRegularNoir().color
        ui_label_description.text = "neighborhood_add_post_image_info_move".localized
        
        ui_top_view.populateView(title: "", titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self)
        
        self.ui_iv_preview.image = self.currentImage
        self.ui_scrollview.maximumZoomScale = 10
        self.ui_scrollview.layer.cornerRadius = cornerRadiusImage
        self.ui_scrollview.layer.borderColor = UIColor.appOrangeLight.cgColor
        self.ui_scrollview.layer.borderWidth = 2
        
        ui_bt_valide.isHidden = false
        ui_top_view.isHidden = false
        
        ui_bt_valide.titleLabel?.font = ApplicationTheme.getFontBoutonBlanc().font
        ui_bt_valide.setTitleColor(.white, for: .normal)
        ui_bt_valide.tintColor = .white
        ui_bt_valide.backgroundColor = .appOrange
        ui_bt_valide.layer.cornerRadius = ui_bt_valide.frame.height / 2
        ui_bt_valide.setTitle("neighborhood_add_post_image_bt_validate".localized, for: .normal)
        
        ui_bt_cancel.titleLabel?.font = ApplicationTheme.getFontBoutonOrange().font
        ui_bt_cancel.setTitleColor(.appOrange, for: .normal)
        ui_bt_cancel.tintColor = .appOrange
        ui_bt_cancel.backgroundColor = .appOrangeLight_50
        ui_bt_cancel.layer.cornerRadius = ui_bt_cancel.frame.height / 2
        ui_bt_cancel.setTitle("neighborhood_add_post_image_bt_cancel".localized, for: .normal)
    }
    
    //MARK: - Methods Images -
    func processImage() -> UIImage? {
        return self.cropVisibleArea()
    }
    
    func cropVisibleArea() -> UIImage? {
        guard let imageToCrop = ui_iv_preview.image else {
            return nil
        }
        if ui_scrollview.zoomScale == 1 {
            return imageToCrop
        }
        
        let cropRect = CGRect(x: ui_view_crop.frame.origin.x - ui_iv_preview.realImageRect().origin.x,
                              y: ui_view_crop.frame.origin.y - ui_iv_preview.realImageRect().origin.y,
                              width: ui_view_crop.frame.width,
                              height: ui_view_crop.frame.height)
        
        let croppedImage = cropImage(imageToCrop,toRect: cropRect, imageViewWidth: ui_iv_preview.frame.width,imageViewHeight: ui_iv_preview.frame.height)
        let img = croppedImage
        
        return img
    }
    
    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, imageViewWidth: CGFloat, imageViewHeight: CGFloat) -> UIImage? {
        let imageViewScale = max(inputImage.size.width / imageViewWidth,
                                 inputImage.size.height / imageViewHeight)
        
        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x: cropRect.origin.x * imageViewScale,
                              y: cropRect.origin.y * imageViewScale,
                              width: cropRect.size.width * imageViewScale,
                              height: cropRect.size.height * imageViewScale)
        
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to: cropZone)
        else {
            return nil
        }
        
        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
    
    //MARK: - IBActions -
    @IBAction func action_cancel(_ sender: Any) {
        goBack()
    }
    
    @IBAction func action_validate(_ sender: Any) {
        
        delegate?.updatePhoto(image: self.processImage())
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - UIScrollViewDelegate -
extension NeighborhoodPostPicturePreviewResizeViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.ui_iv_preview
    }
}

//MARK: - MJNavBackViewDelegate -
extension NeighborhoodPostPicturePreviewResizeViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
