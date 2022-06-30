//
//  EventCreatePhase1ViewController.swift
//  entourage
//
//  Created by Jerome on 21/06/2022.
//

import UIKit
import IQKeyboardManagerSwift

class EventCreatePhase1ViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    weak var pageDelegate:EventCreateMainDelegate? = nil
    
    //Use for growing Textview
    var hasGrowingTV = false
    
    var image:EventImage? = nil
    var event_title:String? = nil
    var event_description:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellsNib()
        IQKeyboardManager.shared.enable = true
        //Use for growing Textview
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveFromGrow), name: Notification.Name(kNotifGrowTextview), object: nil)
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        ui_tableview.rowHeight = UITableView.automaticDimension
        ui_tableview.estimatedRowHeight = 50
    }
    
    
    //Use for growing Textview
    @objc func moveFromGrow(notification: NSNotification) {
        guard let isUp = notification.userInfo?[kNotifGrowTextviewKeyISUP] as? Bool else {return}
        hasGrowingTV = true
        animateViewMoving(isUp, moveValue: 18)
    }
    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if hasGrowingTV {
            UIView.beginAnimations( "animateView", context: nil)
            self.view.frame.origin.y = 0
            UIView.commitAnimations()
            hasGrowingTV = false
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerCellsNib() {
        ui_tableview.register(UINib(nibName: AddDescriptionTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: AddDescriptionTableViewCell.identifier)
        ui_tableview.register(UINib(nibName: AddDescriptionFixedTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: AddDescriptionFixedTableViewCell.identifier)
        
    }
    
    @IBAction func action_show_images(_ sender: Any) {
        self.pageDelegate?.showChooseImage(delegate: self)
    }
}
//MARK: - UITableView datasource / Delegate -
extension EventCreatePhase1ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellGroupName", for: indexPath) as! NeighborhoodCreateNameCell
            cell.populateCell(delegate: self,name: event_title, isEvent: true)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddDescriptionTableViewCell.identifier, for: indexPath) as! AddDescriptionTableViewCell
            
            let titleAttributted = Utils.formatString(messageTxt: "event_create_phase_1_desc".localized, messageTxtHighlight: "event_create_mandatory".localized, fontColorType: ApplicationTheme.getFontH2Noir(), fontColorTypeHighlight: ApplicationTheme.getFontLegend())
            
            cell.populateCell(title: "",titleAttributted: titleAttributted, description: "event_create_phase_1_desc_subtitle".localized, placeholder: "event_create_phase_1_desc_placeholder".localized, delegate: self,about: event_description, textInputType:.descriptionAbout)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPhoto", for: indexPath) as! NeighborhoodCreatePhotoCell
            
            var imgUrl:String?
            if let img = image?.url_image_portrait {
                imgUrl = img
            }
            else if let img = image?.url_image_landscape {
                imgUrl = img
            }
            
            cell.populateCell(urlImg: imgUrl,isEvent: true)
            
            return cell
        }
    }
}

//MARK: - Delegates -
extension EventCreatePhase1ViewController: ChoosePictureEventDelegate {
    func selectedPicture(image:EventImage) {
        Logger.print("***** image ? \(image)")
        pageDelegate?.addPhoto(image: image)
        self.image = image
        self.ui_tableview.reloadData()
    }
}

extension EventCreatePhase1ViewController: AddDescriptionCellDelegate {
    func updateFromTextView(text: String?, textInputType: TextInputType) {
        self.event_description = text
        pageDelegate?.addDescription(text)
    }
}

extension EventCreatePhase1ViewController: NeighborhoodCreateNameCellDelegate {
    func updateFromGroupNameTF(text:String?) {
        self.event_title = text
        pageDelegate?.addTitle(text!)
    }
}

