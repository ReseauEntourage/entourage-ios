//
//  OTEntourageEditPhotoGalleryViewController.swift
//  entourage
//
//  Created by Jr on 18/05/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTEntourageEditPhotoGalleryViewController: UIViewController {
    
    @IBOutlet weak var ui_label_information: UILabel!
    @IBOutlet weak var ui_tableview: UITableView!
    @objc var entourage:OTEntourage?
    @objc var delegate:EditPhotoGalleryDelegate?
    
    var arrayPhotos = [PhotoGallery]()
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getGallery()
        
        ui_label_information.text = OTLocalisationService.getLocalizedValue(forKey: "title_add_photo_gallery")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: OTLocalisationService.getLocalizedValue(forKey: "title_save_button_photo_gallery"), style: .plain, target: self, action: #selector(savePhoto))
        
        changeValidateButton()
    }
    
    func getGallery() {
        OTEntourageEditorService.getGalleryPhoto(withParams: nil) { photos, error in
            if let _photos = photos {
                self.arrayPhotos.removeAll()
                self.arrayPhotos.append(contentsOf: _photos)
                for i in 0..<self.arrayPhotos.count {
                    if self.arrayPhotos[i].url_image_landscape == self.entourage?.entourage_event_url_image_landscape {
                        self.selectedIndex = i
                        break
                    }
                }
                DispatchQueue.main.async {
                    self.ui_tableview.reloadData()
                }
            }
        }
    }
    
    func changeValidateButton() {
        if selectedIndex != -1 {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    @objc func savePhoto() {
        let photo = arrayPhotos[selectedIndex]
        delegate?.editingValidated(photo.url_image_portrait, andBigImage: photo.url_image_landscape)
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - UITableViewDelegate,UITableViewDataSource -
extension OTEntourageEditPhotoGalleryViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayPhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPhoto", for: indexPath) as! CellPhotoGallery
        
        let isSelected = selectedIndex == indexPath.row
        cell.populateCell(imageUrl: arrayPhotos[indexPath.row].url_image_landscape_light, isSelected: isSelected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndex == indexPath.row {
            selectedIndex = -1
        }
        else {
            selectedIndex = indexPath.row
        }
        tableView.reloadData()
        changeValidateButton()
    }
}

//MARK: - PhotoGallery Obj -
struct PhotoGallery {
    var url_image_landscape = ""
    var url_image_landscape_light = ""
    var url_image_portrait = ""
    var image_title = ""
    
    static func parsingPhotos(dict:[String:Any]) -> [PhotoGallery]? {
        var returnGallery:[PhotoGallery]? = nil
        
        if let _array = dict["entourage_images"] as? [[String:Any]]  {
            returnGallery = [PhotoGallery]()
            for _item in _array {
                var photo = PhotoGallery()
                if let _img = _item["portrait_url"] as? String {
                    photo.url_image_portrait = _img
                }
                if let _img = _item["landscape_url"] as? String {
                    photo.url_image_landscape = _img
                }
                if let _title = _item["title"] as? String {
                    photo.image_title = _title
                }
                if let _img = _item["landscape_small_url"] as? String {
                    photo.url_image_landscape_light = _img
                }
                
                returnGallery?.append(photo)
            }
        }
        return returnGallery
    }
}

//MARK: - CellPhotoGallery -
class CellPhotoGallery: UITableViewCell {
    
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_img_select: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_img_select.layer.cornerRadius = ui_img_select.frame.width / 2
        ui_img_select.backgroundColor = UIColor.init(displayP3Red: 218 / 255.0, green: 218 / 255.0, blue: 218 / 255.0, alpha: 1.0)
    }
    
    func populateCell(imageUrl:String, isSelected:Bool) {
        if let url = URL(string: imageUrl) {
            ui_image.setImageWith(url, placeholderImage: UIImage.init(named: ""))
        }
        
        if isSelected {
            ui_img_select.image = UIImage.init(named: "24HSelected")
        }
        else {
            ui_img_select.image = UIImage.init(named: "")
        }
    }
}
