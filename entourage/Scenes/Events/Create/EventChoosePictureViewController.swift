//
//  EventChoosePictureViewController.swift
//  entourage
//
//  Created by Jerome on 24/06/2022.
//

import UIKit
import Mantis

class EventChoosePictureViewController: BasePopViewController {
    
    @IBOutlet weak var ui_view_error: MJErrorInputView!
    @IBOutlet weak var ui_collectionview: UICollectionView!
    @IBOutlet weak var ui_bt_validate: UIButton!
    
    let numberofItemsByLine: CGFloat = 3
    
    var selectedImagePos = -1
    
    var images = [EventImage]()
    
    weak var delegate:ChoosePictureEventDelegate? = nil
    
    var hasCustomAddImageRights: Bool {
        guard let user = UserDefaults.currentUser else { return false }
        if user.partner != nil { return true }
        if let roles = user.roles, roles.contains("Équipe Entourage") || roles.contains("Equipe") { return true }
        if user.isAmbassador() { return true }
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_view_container.backgroundColor = .appBeigeClair
        
        ui_bt_validate.layer.cornerRadius = ui_bt_validate.frame.height / 2
        ui_bt_validate.setTitleColor(.white, for: .normal)
        ui_bt_validate.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 18)
        ui_bt_validate.setTitle("neighborhood_choosephoto_validate".localized, for: .normal)
        configureOrangeButton(ui_bt_validate, withTitle: "neighborhood_choosephoto_validate".localized)
        
        ui_view_error.populateView(backgroundColor: .white.withAlphaComponent(0.6))
        ui_view_error.changeTitleAndImage(title: "neighborhood_choosephoto_error".localized)
        ui_view_error.hide()
        
        ui_top_view.populateView(title: "neighborhood_choosephoto_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
        
        ui_collectionview.delegate = self
        ui_collectionview.dataSource = self
        
        setupFlowLayout()
        
        getImages()
        changeButtonSelection()
        AnalyticsLoggerManager.logEvent(name: View_NewGroup_Step3_PicGallery)
    }
    
    func setupFlowLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 29
        layout.minimumLineSpacing = 20
        let _size = view.frame.width - (layout.minimumInteritemSpacing * numberofItemsByLine - 1) / numberofItemsByLine
        layout.itemSize = CGSize(width: _size, height: _size)
        ui_collectionview.collectionViewLayout = layout
    }
    
    func getImages() {
        EventService.getEventImages { eventsImages, error in
            if let images = eventsImages {
                self.images = images
            }
            else {
                self.goBack()
            }
            self.ui_collectionview.reloadData()
        }
    }
    
    func changeButtonSelection() {
        if selectedImagePos == -1 {
            ui_bt_validate.backgroundColor = ui_bt_validate.backgroundColor?.withAlphaComponent(0.4)
        }
        else {
            ui_bt_validate.backgroundColor = .appOrange
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

    
    @IBAction func action_validate(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Action_NewGroup_Step3_PicGallery_Validate)
        if selectedImagePos >= 0 {
            let dataIndex = hasCustomAddImageRights ? selectedImagePos - 1 : selectedImagePos
            delegate?.selectedPicture(image: images[dataIndex])
            self.dismiss(animated: true)
        }
        else {
            //TODO: error ?
            ui_view_error.show()
        }
    }
}

//MARK: - CollectionView delegate / datasource / flowLayout -
extension EventChoosePictureViewController: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hasCustomAddImageRights ? images.count + 1 : images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if hasCustomAddImageRights && indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellImage", for: indexPath) as! NeighborhoodChoosePhotoCell
            cell.ui_image.image = UIImage(named: "ic_plus")?.withRenderingMode(.alwaysTemplate)
            cell.ui_image.tintColor = .appOrange
            cell.ui_image.contentMode = .center
            cell.ui_contentview.backgroundColor = .appBeige
            cell.ui_contentview.layer.borderWidth = 1
            cell.ui_contentview.layer.borderColor = UIColor.appOrangeLight.cgColor
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellImage", for: indexPath) as! NeighborhoodChoosePhotoCell
        cell.ui_image.contentMode = .scaleAspectFill
        
        let dataIndex = hasCustomAddImageRights ? indexPath.row - 1 : indexPath.row
        let image = images[dataIndex]
        
        let isSelected = selectedImagePos == indexPath.row
        
        var imgUrl = ""
        
        if let img = image.url_image_portrait {
            imgUrl = img
        }
        else if let img = image.url_image_landscape {
            imgUrl = img
        }
        
        cell.populateCell(imageUrl: imgUrl, isSelected: isSelected)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if hasCustomAddImageRights && indexPath.row == 0 {
            showPicker()
            return
        }

        selectedImagePos = indexPath.row == selectedImagePos ? -1 : indexPath.row
        collectionView.reloadData()
        self.changeButtonSelection()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let collectionViewWidth = self.ui_collectionview.bounds.width
        let space = (numberofItemsByLine - 1) * flowLayout.minimumInteritemSpacing
        let width = Int((collectionViewWidth - space) / numberofItemsByLine)
        
        return CGSize(width: width, height: width)
    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension EventChoosePictureViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        if let image = info[.originalImage] as? UIImage {
            var config = Mantis.Config()
            config.cropViewConfig.cropShapeType = .rect
            config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 16.0 / 9.0)
            let cropViewController = Mantis.cropViewController(image: image, config: config)
            cropViewController.delegate = self
            cropViewController.modalPresentationStyle = .fullScreen
            self.present(cropViewController, animated: true)
        }
    }
}

//MARK: - CropViewControllerDelegate
extension EventChoosePictureViewController: CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation, cropInfo: Mantis.CropInfo) {
        cropViewController.dismiss(animated: true) {
            if let phase1Delegate = self.delegate as? EventCreatePhase1ViewController {
                phase1Delegate.pageDelegate?.addCustomPhoto(image: cropped)
            } else if let editMainDelegate = self.delegate as? EventEditMainViewController {
                editMainDelegate.addCustomPhoto(image: cropped)
            } else if let mainDelegate = self.delegate as? EventCreateMainDelegate {
                mainDelegate.addCustomPhoto(image: cropped)
            }
            self.dismiss(animated: true)
        }
    }

    func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: true, completion: nil)
    }

    func cropViewControllerDidFailToCrop(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        // Fallback or handle failure
        cropViewController.dismiss(animated: true, completion: nil)
    }

    func cropViewControllerDidBeginResize(_ cropViewController: Mantis.CropViewController) {
    }

    func cropViewControllerDidEndResize(_ cropViewController: Mantis.CropViewController, original: UIImage, cropInfo: Mantis.CropInfo) {
    }
}

//MARK: - MJNavBackViewDelegate -
extension EventChoosePictureViewController: MJNavBackViewDelegate {
    func goBack() {
        AnalyticsLoggerManager.logEvent(name: Action_NewGroup_Step3_PicGallery_Close)
        self.dismiss(animated: true)
    }
    func didTapEvent() {
        //Nothing yet
    }
}

//MARK: - Protocol PlaceViewControllerDelegate -
protocol ChoosePictureEventDelegate: AnyObject {
    func selectedPicture(image:EventImage)
}
