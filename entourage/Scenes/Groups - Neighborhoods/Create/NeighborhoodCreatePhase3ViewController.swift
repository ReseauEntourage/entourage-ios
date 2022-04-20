//
//  NeighborhoodCreatePhase3ViewController.swift
//  entourage
//
//  Created by Jerome on 08/04/2022.
//

import UIKit

class NeighborhoodCreatePhase3ViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    weak var pageDelegate:NeighborhoodCreateMainDelegate? = nil
    
    var image:NeighborhoodImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink
        
        ui_tableview.delegate = self
        ui_tableview.dataSource = self
    }
    
    @IBAction func action_show_choose_photos(_ sender: Any) {
        pageDelegate?.showChoosePhotos(delegate: self)
    }
}

//MARK: - UITableView datasource / Delegate -
extension NeighborhoodCreatePhase3ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellMessage", for: indexPath) as! NeighborhoodCreateDescriptionCell
            cell.populateCell(title: "addPhotoCreateDescriptionTitle", description: "addPhotoCreateDescriptionSubtitle", placeholder: "addPhotoCreateDescriptionPlaceholder", delegate: self,textInputType:.descriptionWelcome)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPhoto", for: indexPath)  as! NeighborhoodCreatePhotoCell
        cell.populateCell(urlImg: image?.imageUrl)
        return cell
    }
}

//MARK: - ChoosePictureNeighborhoodDelegate -
extension NeighborhoodCreatePhase3ViewController: ChoosePictureNeighborhoodDelegate {
    func selectedPicture(image: NeighborhoodImage) {
        Logger.print("***** image ? \(image)")
        pageDelegate?.addGroupPhoto(image: image)
        self.image = image
        self.ui_tableview.reloadData()
    }
}

//MARK: - NeighborhoodCreateDescriptionCellDelegate -
extension NeighborhoodCreatePhase3ViewController:NeighborhoodCreateDescriptionCellDelegate {
    func updateFromTextView(text: String?,textInputType:TextInputType) {
        pageDelegate?.addGroupWelcome(message: text)
    }
}
