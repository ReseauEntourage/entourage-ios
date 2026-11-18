//
//  OTPicturePreviewResizeViewController.swift
//  entourage
//
//  Created by Jr on 27/04/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import SVProgressHUD



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
    let MaxZoomScale:CGFloat = 2.0
    private var laidOutFrameSize: CGSize = .zero
    var isSmallTalkMode: Bool = false

    var isFromProfile = false
    var isFromDeepLink = false
    var pictureSettingDelegate:ImageReUpLoadDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_label_description.font = ApplicationTheme.getFontCourantRegularNoir().font
        ui_label_description.textColor = ApplicationTheme.getFontCourantRegularNoir().color
        ui_label_description.text = "description_move_photo".localized
        
        ui_bt_validate.setTitle("validate".localized, for: .normal)
        ui_bt_cancel.setTitle("cancel".localized, for: .normal)
        ui_bt_valide_from_profile.setTitle("validate".localized, for: .normal)
        
        ui_top_view.populateView(title: "", titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self)
        
        // Comme sur Android (CropMe) : l'image entière est affichée en remplissant le cadre,
        // on peut la déplacer et zoomer jusqu'à x2 maximum (cf. cropme_max_scale = 2.0).
        self.ui_iv_preview.image = self.currentImage
        self.ui_iv_preview.contentMode = .scaleToFill
        self.ui_scrollview.minimumZoomScale = 1
        self.ui_scrollview.maximumZoomScale = MaxZoomScale
        self.ui_scrollview.bouncesZoom = false
        self.ui_scrollview.contentInsetAdjustmentBehavior = .never
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutImageToFillFrame()
    }
    
    /// Affiche l'image en "aspect fill" dans le cadre carré, avec un contenu réellement déplaçable.
    private func layoutImageToFillFrame() {
        guard let image = currentImage, image.size.width > 0, image.size.height > 0 else { return }
        let frameSize = ui_scrollview.bounds.size
        guard frameSize.width > 0, frameSize.height > 0, frameSize != laidOutFrameSize else { return }
        laidOutFrameSize = frameSize
        
        // L'image est positionnée à la main : on retire les contraintes du storyboard
        let imageConstraints = ui_scrollview.constraints.filter { $0.firstItem === ui_iv_preview || $0.secondItem === ui_iv_preview }
        NSLayoutConstraint.deactivate(imageConstraints)
        ui_iv_preview.translatesAutoresizingMaskIntoConstraints = true
        
        ui_scrollview.zoomScale = 1
        let fillScale = max(frameSize.width / image.size.width, frameSize.height / image.size.height)
        let fillSize = CGSize(width: image.size.width * fillScale, height: image.size.height * fillScale)
        ui_iv_preview.frame = CGRect(origin: .zero, size: fillSize)
        ui_scrollview.contentSize = fillSize
        ui_scrollview.contentOffset = CGPoint(x: (fillSize.width - frameSize.width) / 2,
                                              y: (fillSize.height - frameSize.height) / 2)
    }
    
    //MARK: - Methods Images -
    func processImage() -> UIImage? {
        if let _finalImage = self.cropVisibleArea() {
            return _finalImage.resizeTo(size: CGSize(width: MaxImageSize, height: MaxImageSize))
        }
        return nil
    }
    
    func cropVisibleArea() -> UIImage? {
        guard let _currentImg = self.currentImage, let cgImage = _currentImg.cgImage else {
            return nil
        }
        let zoom = self.ui_scrollview.zoomScale
        let imageViewSize = self.ui_iv_preview.bounds.size
        guard imageViewSize.width > 0, imageViewSize.height > 0 else { return nil }
        
        // Zone visible (dans le repère de l'image affichée, sans zoom) -> pixels de l'image source
        let pixelsPerPointX = CGFloat(cgImage.width) / imageViewSize.width
        let pixelsPerPointY = CGFloat(cgImage.height) / imageViewSize.height
        var visibleRect = CGRect(
            x: self.ui_scrollview.contentOffset.x / zoom * pixelsPerPointX,
            y: self.ui_scrollview.contentOffset.y / zoom * pixelsPerPointY,
            width: self.ui_scrollview.bounds.width / zoom * pixelsPerPointX,
            height: self.ui_scrollview.bounds.height / zoom * pixelsPerPointY
        )
        visibleRect = visibleRect.intersection(CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        guard !visibleRect.isNull, visibleRect.width > 0, visibleRect.height > 0 else { return nil }
        
        return self.imageByCropping(image: _currentImg, toCroppedArea: visibleRect.integral)
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
            //  OTLogger.logEvent(Action_Profile_Photo_Submit)
            PictureUploadS3Service.prepareUploadWith(image: _image,completion: { [weak self] isOk in
                if isOk, let self = self {
                    self.pictureSettingDelegate?.reloadOnImageUpdate()
                    self.popToProfile()
                    return
                }
                SVProgressHUD.showError(withStatus: "user_photo_change_error".localized)
            })
            return
        }
    }
    
    func popToProfile() {
        SVProgressHUD.dismiss()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationProfilePictureUpdated), object: self)
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - IBActions -
    @IBAction func action_validate(_ sender: Any) {
        guard let processedImage = self.processImage() else { return }

        // 🔸 Toujours notifier immédiatement (optimiste)
        delegate?.updatePhoto(image: processedImage)

        // 🔸 Upload async, mais on a déjà prévenu le delegate
        SVProgressHUD.show()
        PictureUploadS3Service.prepareUploadWith(image: processedImage) { [weak self] isOk in
            guard let self = self else { return }

            if isOk {
                self.pictureSettingDelegate?.reloadOnImageUpdate()
                self.navigationController?.popViewController(animated: true)
                SVProgressHUD.dismiss()
            } else {
                SVProgressHUD.showError(withStatus: "user_photo_change_error".localized)
            }
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
    func didTapEvent() {
        //Nothing yet
    }
    
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
