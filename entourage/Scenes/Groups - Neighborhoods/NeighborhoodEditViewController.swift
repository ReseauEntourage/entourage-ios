//
//  NeighborhoodEditViewController.swift
//  entourage
//
//  Created by Jerome on 14/04/2022.
//

import UIKit
import CoreLocation
import GooglePlaces
import IHProgressHUD

class NeighborhoodEditViewController: UIViewController {
    
    @IBOutlet weak var ui_container_view: UIView!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_view_error: MJErrorInputView!
    @IBOutlet weak var ui_tableview: UITableView!
    
    @IBOutlet weak var ui_view_button: UIView!
    @IBOutlet weak var ui_button_validate: UIButton!
    
    @IBOutlet weak var ui_bt_validate_bottom_constraint: NSLayoutConstraint!
    
    var location_new:CLLocationCoordinate2D? = nil
    var location_name_new:String? = nil
    var location_googlePlace_new:GMSPlace? = nil
    
    var isFromPlaceSelection = false
    
    //Phase 1
    var neighborhoodName:String? = nil
    var neighborhoodAbout:String? = nil
    
    //Phase 2
    var tagsInterests:Tags! = nil
    var showEditOther = false
    var messageOther:String? = nil
    
    //Phase 3
    var neighborhoodWelcome:String? = nil
    var image:NeighborhoodImage? = nil
    
    var currentNeighborhoodId = 22 // TODO: a supprimer et mettre 0
    var currentNeighborhood:Neighborhood? = nil
    var isValidationEnabled = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        ui_tableview.rowHeight = UITableView.automaticDimension
        ui_tableview.estimatedRowHeight = 50
        
        ui_view_error.hide()
        
        ui_container_view.backgroundColor = .appBeigeClair
        
        ui_view_button.layer.cornerRadius = ui_view_button.frame.height / 2
        ui_button_validate.layer.cornerRadius = ui_button_validate.frame.height / 2
        ui_button_validate.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 18)
        ui_button_validate.setTitleColor(.white, for: .normal)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        ui_top_view.populateCustom(title: "neighborhood_edit_group_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 24), titleColor: .white, imageName: "back_button_white", backgroundColor: .clear, delegate: self, showSeparator: false)
        
        ui_tableview.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        ui_tableview.layer.maskedCorners = CACornerMask.radiusTopOnly()
        ui_container_view.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        ui_container_view.layer.maskedCorners = CACornerMask.radiusTopOnly()
        
        tagsInterests = Metadatas.sharedInstance.tagsInterest
        
        getCurrentNeighBorhood()
        
        if ApplicationTheme.iPhoneHasNotch() {
            ui_bt_validate_bottom_constraint.constant = 0
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height , right: 0.0)
        ui_tableview.contentInset = contentInsets
        ui_tableview.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        ui_tableview.contentInset = contentInsets
        ui_tableview.scrollIndicatorInsets = contentInsets
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func action_send(_ sender: Any) {
        checkValidation()
    }
    
    func getCurrentNeighBorhood() {
        NeighborhoodService.getNeighborhoodDetail(id: currentNeighborhoodId) { group, error in
            if let _ = error {
                //TODO: afficher erreur ?
                self.goBack()
                return
            }
            self.currentNeighborhood = group
            
            if let interests = self.currentNeighborhood?.interests {
                for interest in interests {
                    if let _ = self.tagsInterests?.getTagNameFrom(key: interest) {
                        self.tagsInterests?.checkUncheckTagFrom(key: interest, isCheck: true)
                    }
                }
            }
            self.ui_tableview.reloadData()
        }
    }
    
    func checkValidationInputs() {
        var isValidated = true
        
        if neighborhoodName !=  nil && !(neighborhoodName?.count ?? 0 >= ApplicationTheme.minGroupNameChars)  {
            isValidated = false
        }
        else {
            var isValidTag = false
            for tag in tagsInterests.getTags() {
                if tag.isSelected {
                    isValidTag = true
                    break
                }
            }
            isValidated = isValidTag
        }
        enableDisableButton(isEnable: isValidated)
    }
    
    func enableDisableButton(isEnable:Bool) {
        isValidationEnabled = isEnable
        if isEnable {
            ui_button_validate.alpha = 1.0
        }
        else {
            ui_button_validate.alpha = 0.4
        }
    }
    
    func checkValidation() {
        
        if !isValidationEnabled {
            ui_view_error.changeTitleAndImage(title: "neighborhoodEdit_error".localized)
            ui_view_error.show()
            return
        }
        
        var newNeighborhood = Neighborhood()
        newNeighborhood.uid = currentNeighborhoodId
        
        if let neighborhoodName = neighborhoodName {
            newNeighborhood.name = neighborhoodName
        }
        
        if let neighborhoodAbout = neighborhoodAbout {
            newNeighborhood.aboutGroup = neighborhoodAbout
        }
        
        if let location_new = location_new {
            let location = CLLocation(latitude: location_new.latitude, longitude: location_new.longitude)
            newNeighborhood.address = Address(displayAddress: location_name_new, location: location)
        }
        else if let googlePlace = location_googlePlace_new {
            let location = CLLocation(latitude: googlePlace.coordinate.latitude, longitude: googlePlace.coordinate.longitude)
            newNeighborhood.address?.location = location
            newNeighborhood.address = Address(displayAddress: googlePlace.name, location: location)
        }
        
        //Phase 2
        let tags = tagsInterests.getTagsForWS()
        if tags.count > 0 {
            newNeighborhood.interests = tags
        }
        
        //Phase 3
        if let neighborhoodWelcome = neighborhoodWelcome {
            newNeighborhood.welcomeMessage = neighborhoodWelcome
        }
        
        if let imageUrl = image?.imageUrl {
            newNeighborhood.image_url = imageUrl
        }
        
        if let uid = image?.uid {
            newNeighborhood.neighborhood_image_id = uid
        }
        updateNeighborhood(newNeighborhood)
    }
    
    func updateNeighborhood(_ newNeighborhood:Neighborhood) {
        NeighborhoodService.updateNeighborhood(group: newNeighborhood) { group, error in
            Logger.print("***** return update NeighB : \(group) ----- error \(error)")
            //TODO: on fait quoi après on ferme la page ?
            IHProgressHUD.showSuccesswithStatus("neighborhoodEditValidateTitle".localized)
        }
    }
    
    @IBAction func action_show_photos(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "neighborhoodChoosePhotoVC") as? NeighborhoodChoosePictureViewController {
            vc.delegate = self
            self.present(vc, animated: true)
        }
    }
}

//MARK: - UITableView datasource / Delegate -
extension NeighborhoodEditViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentNeighborhood == nil ? 0 : 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentNeighborhood == nil { return 0 }
        
        switch section {
        case 0:
            return 3 + 1 //Header
        case 1:
            if showEditOther {
                return tagsInterests.getTags().count + 1 + 2 //Header + description
            }
            return tagsInterests.getTags().count + 2 // 2 -> Header + description
        case 2:
            return 2 + 1 //Header
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return populateSection0(indexPath: indexPath)
        case 1:
            return populateSection1(indexPath: indexPath)
        case 2:
            return populateSection2(indexPath: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    func populateSection0(indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = self.ui_tableview.dequeueReusableCell(withIdentifier: "cellHeader", for: indexPath) as! NeighborhoodEditHeaderCell
            cell.populateCell(position: 1)
            return cell
        case 1:
            let cell = self.ui_tableview.dequeueReusableCell(withIdentifier: "cellGroupName", for: indexPath) as! NeighborhoodCreateNameCell
            let _name = neighborhoodName == nil ? currentNeighborhood?.name : neighborhoodName
            cell.populateCell(delegate: self, name: _name)
            return cell
        case 2:
            let cell = self.ui_tableview.dequeueReusableCell(withIdentifier: "cellGroupDescription", for: indexPath) as! NeighborhoodCreateDescriptionCell
            let msgAbout = neighborhoodAbout == nil ? currentNeighborhood?.aboutGroup : neighborhoodAbout
            
            cell.populateCell(title: "neighborhoodCreateDescriptionTitle", description: "neighborhoodCreateDescriptionSubtitle", placeholder: "neighborhoodCreateTitleDescriptionPlaceholder", delegate: self, about: msgAbout ,textInputType:.descriptionAbout)
            return cell
        default:
            //TODO: voir lorsque le WS sera ok pour la location
            let cell = self.ui_tableview.dequeueReusableCell(withIdentifier: "cellGroupPlace", for: indexPath) as! NeighborhoodCreateLocationCell
            
            var showError = false
            var cityName:String? = nil
            if isFromPlaceSelection {
                self.isFromPlaceSelection = false
                if let _cityName = self.location_name_new {
                    cityName = _cityName
                }
                else if let _gplace = self.location_googlePlace_new?.formattedAddress { //TODO: quel formattage d'adresse ?
                    cityName = _gplace
                }
                showError = cityName == nil
            }
            else {
                cityName = currentNeighborhood?.address?.displayAddress
            }
            
            cell.populateCell(delegate: self, showError: showError, cityName:cityName)
            
            return cell
        }
    }
    
    func populateSection1(indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = self.ui_tableview.dequeueReusableCell(withIdentifier: "cellHeader", for: indexPath) as! NeighborhoodEditHeaderCell
            cell.populateCell(position: 2)
            return cell
        case 1:
            let cell = self.ui_tableview.dequeueReusableCell(withIdentifier: "cellInterestTitle", for: indexPath) as! TitleOnlyCell
            
            let style = ApplicationTheme.getFontH2Noir()
            let styleHighlight = ApplicationTheme.getFontLegend()
            let attrStr = Utils.formatString(messageTxt: "neighborhoodEditCatMessage".localized, messageTxtHighlight: "neighborhoodEditCatMessageHighlight".localized, fontColorType: style, fontColorTypeHighlight: styleHighlight)
            
            cell.populateCell(attributedStr:attrStr)
            return cell
        default:
            break
        }
        
        if showEditOther && indexPath.row == tagsInterests.getTags().count + 2 {
            let cell = self.ui_tableview.dequeueReusableCell(withIdentifier: "cellOther", for: indexPath) as! NeighborhoodCreateAddOtherCell
            
            cell.populateCell(currentWord:messageOther , delegate: self)
            
            return cell
        }
        
        let cell = self.ui_tableview.dequeueReusableCell(withIdentifier: "cellInterest", for: indexPath) as! SelectTagCell
        
        let interest = tagsInterests?.getTags()[indexPath.row - 2]
        let hideSelector = (indexPath.row - 1) == tagsInterests.getTags().count ? true : false
        
        cell.populateCell(title: tagsInterests!.getTagNameFrom(key: interest!.name) , isChecked: interest!.isSelected, imageName: (interest! as! TagInterest).tagImageName, hideSeparator: hideSelector)
        
        return cell
    }
    
    func populateSection2(indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = self.ui_tableview.dequeueReusableCell(withIdentifier: "cellHeader", for: indexPath) as! NeighborhoodEditHeaderCell
            cell.populateCell(position: 3)
            return cell
        case 1:
            let cell = self.ui_tableview.dequeueReusableCell(withIdentifier: "cellMessage", for: indexPath) as! NeighborhoodCreateDescriptionCell
            let msgWelcome = neighborhoodWelcome == nil ? currentNeighborhood?.welcomeMessage : neighborhoodWelcome
            
            cell.populateCell(title: "addPhotoCreateDescriptionTitle", description: "addPhotoCreateDescriptionSubtitle", placeholder: "addPhotoCreateDescriptionPlaceholder", delegate: self,about: msgWelcome,textInputType:.descriptionWelcome)
            return cell
        default:
            let cell = self.ui_tableview.dequeueReusableCell(withIdentifier: "cellPhoto", for: indexPath)  as! NeighborhoodCreatePhotoCell
            cell.populateCell(urlImg: currentNeighborhood?.image_url, isEdit: true)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 1 { return }
        
        if indexPath.row < 2 { return }
        
        if showEditOther && indexPath.row == tagsInterests.getTags().count + 2 { return }
        let isCheck = tagsInterests!.getTags()[indexPath.row - 2].isSelected
        
        tagsInterests?.checkUncheckTagFrom(position: indexPath.row - 2, isCheck: !isCheck)
        
        let isTagOther = tagsInterests.getTags()[indexPath.row - 2].name == Tag.tagOther
        
        if (indexPath.row == tagsInterests.getTags().count - 1 + 2) && isTagOther {
            //Ajout une ligne +
            showEditOther = tagsInterests.getTags()[indexPath.row - 2].isSelected
            if showEditOther {
                self.reloadData(animated: true)
            }
            else {
                self.reloadData(animated: false)
            }
        }
        else {
            tableView.reloadData()
        }
        messageOther = showEditOther ? messageOther : nil
        self.checkValidationInputs()
    }
    
    func reloadData(animated:Bool){
        ui_tableview.reloadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05, execute: {
            let scrollPoint = CGPoint(x: 0, y: self.ui_tableview.contentSize.height - self.ui_tableview.frame.size.height)
            self.ui_tableview.setContentOffset(scrollPoint, animated: animated)
        })
    }
}

//MARK: - NeighborhoodCreateDescriptionCellDelegate / NeighborhoodCreateLocationCellDelegate -
extension NeighborhoodEditViewController: NeighborhoodCreateDescriptionCellDelegate, NeighborhoodCreateLocationCellDelegate, NeighborhoodCreateNameCellDelegate {
    func updateFromTextView(text: String?,textInputType:TextInputType) {
        switch textInputType {
        case .descriptionAbout:
            neighborhoodAbout = text
        case .descriptionWelcome:
            neighborhoodWelcome = text
        case .none:
            break
        }
        checkValidationInputs()
    }
    
    func showSelectLocation() {
        let sb = UIStoryboard.init(name: "ProfileParams", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "place_choose_vc") as? ParamsChoosePlaceViewController {
            vc.placeVCDelegate = self
            self.present(vc, animated: true)
        }
    }
    
    func updateFromGroupNameTF(text: String?) {
        neighborhoodName = text
        checkValidationInputs()
    }
}

//MARK: - PlaceViewControllerDelegate -
extension NeighborhoodEditViewController: PlaceViewControllerDelegate {
    func modifyPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        self.location_name_new = currentLocationName
        self.location_new = currentlocation
        self.location_googlePlace_new = googlePlace
        
        DispatchQueue.main.async {
            self.isFromPlaceSelection = true
            self.ui_tableview.reloadData()
            self.checkValidationInputs()
        }
    }
}

//MARK: - MJNavBackViewDelegate -
extension NeighborhoodEditViewController: MJNavBackViewDelegate {
    func goBack() { //TODO: on affiche la pop de warning ?
        self.dismiss(animated: true)
        //        let alertVC = MJAlertController()
        //        let buttonCancel = MJAlertButtonType(title: "neighborhoodCreatePopCloseBackCancel".localized, titleStyle:ApplicationTheme.getFontCourantRegularNoir(size: 18, color: .white), bgColor: .appOrange, cornerRadius: -1)
        //        let buttonValidate = MJAlertButtonType(title: "neighborhoodCreatePopCloseBackQuit".localized, titleStyle:ApplicationTheme.getFontCourantRegularNoir(size: 18, color: .white), bgColor: .appOrangeLight_50, cornerRadius: -1)
        //        alertVC.configureAlert(alertTitle: "neighborhoodCreatePopCloseBackTitle".localized, message: "neighborhoodCreatePopCloseBackMessage".localized, buttonrightType: buttonCancel, buttonLeftType: buttonValidate, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true, parentVC: self)
        //
        //        alertVC.delegate = self
        //        alertVC.show()
    }
}

//MARK: - MJAlertControllerDelegate -
extension NeighborhoodEditViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag: MJAlertTAG) {
        self.dismiss(animated: true)
    }
    func validateRightButton(alertTag: MJAlertTAG) {}
}

//MARK: - NeighborhoodCreateAddOtherDelegate - Phase 2
extension NeighborhoodEditViewController: NeighborhoodCreateAddOtherDelegate {
    func addMessage(_ message: String?) {
        self.messageOther = message
        checkValidationInputs()
    }
}

//MARK: - ChoosePictureNeighborhoodDelegate -
extension NeighborhoodEditViewController: ChoosePictureNeighborhoodDelegate {
    func selectedPicture(image: NeighborhoodImage) {
        self.image = image
        self.currentNeighborhood?.image_url = image.imageUrl
        self.ui_tableview.reloadData()
        checkValidationInputs()
    }
}
