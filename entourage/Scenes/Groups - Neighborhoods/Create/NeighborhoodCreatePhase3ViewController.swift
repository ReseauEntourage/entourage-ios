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
    var group_welcome:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink
        
        ui_tableview.register(UINib(nibName: AddDescriptionTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: AddDescriptionTableViewCell.identifier)
        ui_tableview.register(UINib(nibName: AddDescriptionFixedTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: AddDescriptionFixedTableViewCell.identifier)
        
        ui_tableview.delegate = self
        ui_tableview.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsLoggerManager.logEvent(name: View_NewGroup_Step3)
    }
    
    @IBAction func action_show_choose_photos(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Action_NewGroup_Step3_AddPicture)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: AddDescriptionTableViewCell.identifier, for: indexPath) as! AddDescriptionTableViewCell
            cell.populateCell(title: "addPhotoCreateDescriptionTitle".localized, description: "addPhotoCreateDescriptionSubtitle".localized, placeholder: "addPhotoCreateDescriptionPlaceholder".localized, delegate: self,about: group_welcome,textInputType:.descriptionWelcome, charMaxLimit: ApplicationTheme.maxCharsDescription200, showError: false, tableview: ui_tableview)
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

//MARK: - AddDescriptionCellDelegate -
extension NeighborhoodCreatePhase3ViewController:AddDescriptionCellDelegate {
    func updateFromTextView(text: String?,textInputType:TextInputType) {
        group_welcome = text
        pageDelegate?.addGroupWelcome(message: text)
    }
}
