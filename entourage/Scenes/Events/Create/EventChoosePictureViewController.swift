//
//  EventChoosePictureViewController.swift
//  entourage
//
//  Created by Jerome on 24/06/2022.
//

import UIKit
import SVProgressHUD

class EventChoosePictureViewController: BasePopViewController {
    
    @IBOutlet weak var ui_view_error: MJErrorInputView!
    @IBOutlet weak var ui_collectionview: UICollectionView!
    @IBOutlet weak var ui_bt_validate: UIButton!
    
    let numberofItemsByLine: CGFloat = 3
    
    var selectedImagePos = -1
    
    var images = [EventImage]()
    var showAddPhoto = false
    
    weak var delegate:ChoosePictureEventDelegate? = nil
    
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
        if let currentUser = UserDefaults.currentUser {
            self.showAddPhoto = currentUser.hasEventCreationImageUploadRole()
        }
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
            delegate?.selectedPicture(image: images[selectedImagePos])
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
        if showAddPhoto {
            return images.count + 1
        }
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellImage", for: indexPath) as! NeighborhoodChoosePhotoCell
        
        if showAddPhoto && indexPath.row == 0 {
            cell.populateCell(imageUrl: "", isSelected: false)
            cell.ui_image.image = UIImage(named: "ic_plus")?.withRenderingMode(.alwaysTemplate)
            cell.ui_image.tintColor = .appOrange
            cell.ui_image.contentMode = .center
            cell.ui_image.backgroundColor = .appBeige
            return cell
        }
        
        let imagePos = showAddPhoto ? indexPath.row - 1 : indexPath.row
        let image = images[imagePos]
        let isSelected = selectedImagePos == imagePos
        
        var imgUrl = ""
        
        if let img = image.url_image_portrait {
            imgUrl = img
        }
        else if let img = image.url_image_landscape {
            imgUrl = img
        }
        
        cell.populateCell(imageUrl: imgUrl, isSelected: isSelected)
        cell.ui_image.contentMode = .scaleAspectFill
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if showAddPhoto && indexPath.row == 0 {
            showImagePicker()
            return
        }

        let imagePos = showAddPhoto ? indexPath.row - 1 : indexPath.row
        selectedImagePos = imagePos == selectedImagePos ? -1 : imagePos
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
    func selectedCustomPicture(image: UIImage, uploadKey: String)
}

//MARK: - Image Picker -
extension EventChoosePictureViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let image = info[.originalImage] as? UIImage {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventPictureResizeVC") as? EventPicturePreviewResizeViewController {
                    vc.currentImage = image
                    vc.delegate = self
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            }
        }
    }
}

extension EventChoosePictureViewController: TakePhotoDelegate {
    func updatePhoto(image: UIImage?) {
        guard let image = image else { return }

        SVProgressHUD.show()

        // upload via EventPictureUploadService
        EventPictureUploadService.prepareUploadWith(image: image) { uploadKey, isOk in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                if isOk, let uploadKey = uploadKey {
                    self.delegate?.selectedCustomPicture(image: image, uploadKey: uploadKey)
                    self.dismiss(animated: true)
                } else {
                    // show error
                    self.ui_view_error.changeTitleAndImage(title: "Erreur lors de l'envoi de l'image")
                    self.ui_view_error.show()
                }
            }
        }
    }
}
