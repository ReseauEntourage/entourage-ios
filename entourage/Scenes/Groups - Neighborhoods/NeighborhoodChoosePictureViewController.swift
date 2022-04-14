//
//  NeighborhoodChoosePictureViewController.swift
//  entourage
//
//  Created by Jerome on 13/04/2022.
//

import UIKit

class NeighborhoodChoosePictureViewController: BasePopViewController {
    
    @IBOutlet weak var ui_view_error: MJErrorInputView!
    @IBOutlet weak var ui_collectionview: UICollectionView!
    @IBOutlet weak var ui_bt_validate: UIButton!
    
    let numberofItemsByLine: CGFloat = 3
    
    var selectedImagePos = -1
    
    var images = [NeighborhoodImage]()
    
    weak var delegate:ChoosePictureNeighborhoodDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_bt_validate.layer.cornerRadius = ui_bt_validate.frame.height / 2
        ui_bt_validate.setTitleColor(.white, for: .normal)
        ui_bt_validate.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 18)
        ui_bt_validate.setTitle("neighborhood_choosephoto_validate".localized, for: .normal)
        
        ui_view_error.populateView(backgroundColor: .white.withAlphaComponent(0.6))
        ui_view_error.changeTitleAndImage(title: "neighborhood_choosephoto_error".localized)
        ui_view_error.hide()
        
        ui_top_view.populateView(title: "neighborhood_choosephoto_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
        
        ui_collectionview.delegate = self
        ui_collectionview.dataSource = self
        
        setupFlowLayout()
        
        getImages()
        changeButtonSelection()
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
        NeighborhoodService.getNeighborhoodImages { images, error in
            if let images = images {
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
    
    @IBAction func action_validate(_ sender: Any) {
        if selectedImagePos >= 0 {
            delegate?.selectedPicture(image: images[selectedImagePos])
            self.goBack()
        }
        else {
            //TODO: error ?
            ui_view_error.show()
        }
    }
}

//MARK: - CollectionView delegate / datasource / flowLayout -
extension NeighborhoodChoosePictureViewController: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellImage", for: indexPath) as! NeighborhoodChoosePhotoCell
        
        let image = images[indexPath.row]
        
        let isSelected = selectedImagePos == indexPath.row
        
        cell.populateCell(imageUrl: image.imageUrl, isSelected: isSelected)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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

//MARK: - MJNavBackViewDelegate -
extension NeighborhoodChoosePictureViewController: MJNavBackViewDelegate {
    func goBack() {
        self.dismiss(animated: true)
    }
}

//MARK: - Protocol PlaceViewControllerDelegate -
protocol ChoosePictureNeighborhoodDelegate: AnyObject {
    func selectedPicture(image:NeighborhoodImage)
}
