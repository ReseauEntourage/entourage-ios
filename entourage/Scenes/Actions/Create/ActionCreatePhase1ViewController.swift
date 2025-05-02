//
//  ActionCreatePhase1ViewController.swift
//  entourage
//
//  Created by Jerome on 01/08/2022.
//

import UIKit
import IQKeyboardManagerSwift

class ActionCreatePhase1ViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    weak var pageDelegate:ActionCreateMainDelegate? = nil
    //Use for growing Textview
    var hasGrowingTV = false
    
    var action_title:String? = nil
    var action_description:String? = nil
    var action_image:UIImage? = nil
    
    var currentAction:Action? = nil
    
    let placeholders: [String: (title: String, description: String)] = [
        "demand_social": ("demand_social_title".localized, "demand_social_description".localized),
        "demand_services": ("demand_services_title".localized, "demand_services_description".localized),
        "demand_clothes": ("demand_clothes_title".localized, "demand_clothes_description".localized),
        "demand_equipment": ("demand_equipment_title".localized, "demand_equipment_description".localized),
        "demand_hygiene": ("demand_hygiene_title".localized, "demand_hygiene_description".localized),
        "contrib_social": ("contrib_social_title".localized, "contrib_social_description".localized),
        "contrib_services": ("contrib_services_title".localized, "contrib_services_description".localized),
        "contrib_clothes": ("contrib_clothes_title".localized, "contrib_clothes_description".localized),
        "contrib_equipment": ("contrib_equipment_title".localized, "contrib_equipment_description".localized),
        "contrib_hygiene": ("contrib_hygiene_title".localized, "contrib_hygiene_description".localized)
    ]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        
        IQKeyboardManager.shared.enable = true
        //Use for growing Textview
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveFromGrow), name: Notification.Name(kNotifGrowTextview), object: nil)
        
        ui_tableview.register(UINib(nibName: AddDescriptionTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: AddDescriptionTableViewCell.identifier)
        ui_tableview.register(UINib(nibName: AddDescriptionFixedTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: AddDescriptionFixedTableViewCell.identifier)
        
        if pageDelegate?.isEdit() ?? false {
            currentAction = pageDelegate?.getCurrentAction()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.ui_tableview.reloadData()
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
}

//MARK: - Tableview Datasource/delegate -
extension ActionCreatePhase1ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pageDelegate?.isContribution() ?? true ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellGroupName", for: indexPath) as! NeighborhoodCreateNameCell
            
            // Récupérer la section sélectionnée et le type d'action
            guard let selectedSection = ActionCreateStateManager.shared.getSection() else {
                print("Aucune section sélectionnée")
                return cell
            }
            
            let isContrib = ActionCreateStateManager.shared.isContrib
            let sectionKey = isContrib ? "contrib_\(selectedSection)" : "demand_\(selectedSection)"
            
            // Récupérer le placeholder pour le titre
            let placeholdersForSection = placeholders[sectionKey] ?? ("", "")
            let _titlePlaceholder = placeholdersForSection.title
            
            // Utiliser le placeholder uniquement pour les actions
            let _title = action_title ?? currentAction?.title ?? ""
            
            // Appel à la fonction populateCell en passant le placeholder uniquement pour les actions
            cell.populateCell(delegate: self, name: _title, isEvent: false, isAction: true, isContrib: isContrib, placeholder: _titlePlaceholder)
            
            return cell
            
        case 1:
            // Ton code pour la description
            let cell = tableView.dequeueReusableCell(withIdentifier: AddDescriptionTableViewCell.identifier, for: indexPath) as! AddDescriptionTableViewCell
            
            let stringAttr = Utils.formatString(messageTxt: "action_create_phase_1_desc".localized, messageTxtHighlight: "action_create_mandatory".localized, fontColorType: ApplicationTheme.getFontH2Noir(size: 15), fontColorTypeHighlight: ApplicationTheme.getFontLegend(size: 13))
            
            // Récupérer la section sélectionnée et le type d'action
            guard let selectedSection = ActionCreateStateManager.shared.getSection() else {
                print("Aucune section sélectionnée")
                return cell
            }
            
            let isContrib = ActionCreateStateManager.shared.isContrib
            let sectionKey = isContrib ? "contrib_\(selectedSection)" : "demand_\(selectedSection)"
            let placeholdersForSection = placeholders[sectionKey] ?? ("", "")
            
            let _placeh = placeholdersForSection.title
            let _descph = placeholdersForSection.description
            let _description = String.init(format: "action_create_phase_1_desc_subtitle".localized, pageDelegate?.isContribution() ?? false ? "action_contrib".localized : "action_solicitation".localized)
            
            let _about = action_description ?? currentAction?.description
            cell.populateCell(title: "action_create_phase_1_desc".localized, titleAttributted: stringAttr, description: _description, placeholder: _descph, delegate: self, about: _about, textInputType: .descriptionAbout, tableview: ui_tableview)
            
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPhoto", for: indexPath) as! ActionCreatePhotoCell
            cell.populateCell(image: action_image, imageUrl: currentAction?.imageUrl)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            if let navvc = storyboard?.instantiateViewController(withIdentifier: "addPhotoNav") as? UINavigationController, let vc = navvc.topViewController as? ActionAddPhotoViewController {
                vc.parentDelegate = self
                self.present(navvc, animated: true)
            }
        }
    }
}

//MARK: - AddDescriptionCellDelegate / NeighborhoodCreateLocationCellDelegate -
extension ActionCreatePhase1ViewController: AddDescriptionCellDelegate, NeighborhoodCreateLocationCellDelegate, NeighborhoodCreateNameCellDelegate {
    func updateFromTextView(text: String?,textInputType:TextInputType) {
        self.action_description = text
        pageDelegate?.addDescription(text)
    }
    
    func showSelectLocation() {}
    
    func updateFromGroupNameTF(text: String?) {
        self.action_title = text
        pageDelegate?.addTitle(text!)
    }
}

//MARK: - TakePhotoDelegate -
extension ActionCreatePhase1ViewController: TakePhotoDelegate {
    func updatePhoto(image: UIImage?) {
        self.action_image = image
        pageDelegate?.addPhoto(image: image)
        ui_tableview.reloadData()
    }
}
