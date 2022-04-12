//
//  ProfileEditorViewController.swift
//  entourage
//
//  Created by Jerome on 18/03/2022.
//

import UIKit
import CoreLocation
import GooglePlaces
import IHProgressHUD

class ProfileEditorViewController: UIViewController {
    
    
    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_error_view: MJErrorInputView!
    @IBOutlet weak var ui_button_validate: UIButton!
    @IBOutlet weak var ui_tableview: UITableView!
    
    var currentUser:User? = nil
    var firstname_new:String? = nil
    var lastname_new:String? = nil
    var description_new:String? = nil
    var birth_date_new:String? = nil
    var email_new:String? = nil
    var radius_new:Int? = nil
    
    var location_new:CLLocationCoordinate2D? = nil
    var location_name_new:String? = nil
    var location_googlePlace_new:GMSPlace? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = UserDefaults.currentUser
        ui_top_view.populateView(title: "editUserProfileTitle".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self)
        
        ui_button_validate.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 18)
        ui_button_validate.titleLabel?.textColor = .white
        ui_button_validate.layer.cornerRadius = ui_button_validate.frame.height / 2
        ui_button_validate.setTitle("editUserProfileValidate".localized, for: .normal)
        
        //TODO: on affiche le fond transparent pour l'alerte ou un fond blanc ?
        ui_error_view.populateView(backgroundColor: .white.withAlphaComponent(0.6))
        ui_error_view.hide()
        
        self.modalPresentationStyle = .fullScreen
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePhotoUser), name: NSNotification.Name(kNotificationProfilePictureUpdated), object: nil)
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
        
        
        // reset back the content inset to zero after keyboard is gone
        ui_tableview.contentInset = contentInsets
        ui_tableview.scrollIndicatorInsets = contentInsets
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - IBactions -
    @IBAction func action_validate(_ sender: Any) {
        self.validateProfile()
    }
    
    @IBAction func action_close(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
    
    //MARK: - Methods -
    @objc func updatePhotoUser() {
        currentUser = UserDefaults.currentUser
        self.ui_tableview.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
    
    private func updateUser() {
        DispatchQueue.main.async {
            self.currentUser = UserDefaults.currentUser
            self.ui_tableview.reloadData()
        }
    }
    
    private func validateProfile() {
        var newUser = currentUser
        
        if let firstname_new = firstname_new {
            if firstname_new.count >= ApplicationTheme.minfirstnameChars  {
                newUser?.firstname = firstname_new
            }
            else {
                showError(message: "editUser_error_firstname".localized)
                return
            }
        }
        
        if let lastname_new = lastname_new {
            if lastname_new.count >= ApplicationTheme.minLastnameChars  {
                newUser?.lastname = lastname_new
            }
            else {
                showError(message: "editUser_error_lastname".localized)
                return
            }
        }
        
        if description_new?.count ?? 0 > 0 {
            if let description_new = description_new, description_new.count > 2  {
                newUser?.about = description_new
            }
            else {
                showError(message: "editUser_error_bio".localized)
                return
            }
        }
        else {
            newUser?.about = ""
        }
        
        if email_new?.count ?? 0 > 0 {
            if email_new?.isValidEmail ?? false {
                newUser?.email = email_new
            }
            else {
                showError(message: "editUser_error_email".localized)
                return
            }
        }
        
        if birth_date_new?.count ?? 0 > 0 {
            if let birth_date_new = birth_date_new, birth_date_new.matchesRegEx("^(0[1-9]|1[0-9]|2[0-9]|3[0-1])-(0[1-9]|1[0-2])")  {
                newUser?.birthday = birth_date_new
            }
            else {
                showError(message: "editUser_error_birthday".localized)
                return
            }
        }
        else if !(currentUser?.birthday?.count ?? 0 > 0) {
            newUser?.birthday = ""
        }
        
        if let radius_new = radius_new {
            newUser?.radiusDistance = radius_new
        }
        
        //TODO: la location à la validation ou lors du choix de l'adresse ?
        //check google place
        if let gplace = location_googlePlace_new, let placeId = gplace.placeID {
            UserService.updateUserAddressWith(placeId: placeId, isSecondaryAddress: false) { error in
                if error?.error == nil {
                    //Clean pour afficher l'adresse retournée depuis le WS on garde ?
                    self.location_googlePlace_new = nil
                }
                
                self.updateUser()
            }
        }
        else if let location = location_new, let locationName = location_name_new {
            UserService.updateUserAddressWith(name: locationName, latitude: location.latitude, longitude: location.longitude, isSecondaryAddress: false) { error in
                if error?.error == nil {
                    //Clean pour afficher l'adresse retournée depuis le WS on garde ?
                    self.location_name_new = nil
                    self.location_new = nil
                }
                self.updateUser()
            }
        }
        
        //[OTLogger logEvent:@"SaveProfileEdits"];
        
        IHProgressHUD.show()
        UserService.updateUser(user: newUser, isOnboarding: false) { user, error in
            IHProgressHUD.dismiss()
            if let _ = error?.error {
               // self.showError(message: "editUser_error_profile".localized)
                self.ui_tableview.reloadData()
                return
            }
            self.dismiss(animated: true)
        }
    }
    
    private func showError(message:String,imageName:String? = nil) {
        ui_error_view.changeTitleAndImage(title: message, imageName: imageName)
        ui_error_view.show()
    }
}

//MARK: - Tableview Datasource / Delegate -
extension ProfileEditorViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPhoto", for: indexPath) as! EditProfilePhotoCell
            
            cell.populateCell(photoUrl: currentUser?.avatarURL, delegate: self)
            return cell
        }
        
        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellInterests", for: indexPath)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EditProfileInfosCell
        
        var cityName = currentUser?.addressPrimary?.displayAddress
        if let _cityName = self.location_name_new {
            cityName = _cityName
        }
        else if let _gplace = self.location_googlePlace_new?.formattedAddress { //TODO: quel formattage d'adresse ?
            cityName = _gplace
        }
        
        cell.populateCell(firstname: currentUser?.firstname, lastname: currentUser?.lastname , bio: currentUser?.about, birthdate: currentUser?.birthday, email: currentUser?.email,phone: currentUser?.phone, cityName: cityName, radius: currentUser?.radiusDistance, delegate: self)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            if let vc = UIStoryboard.init(name: "ProfileParams", bundle: nil).instantiateViewController(withIdentifier: "editProfileInterestsVC") as? ProfileEditInterestsViewController, Metadatas.sharedInstance.tagsInterest?.getTags().count ?? 0 > 0 {
                vc.tagsInterests = Metadatas.sharedInstance.tagsInterest
                self.navigationController?.present(vc, animated: true)
            }
        }
    }
}

//MARK: - CellTextDelegate -
extension ProfileEditorViewController:CellTextDelegate {
    func updateCellHeight() {
        DispatchQueue.main.async {
            self.ui_tableview?.beginUpdates()
            self.ui_tableview?.endUpdates()
        }
    }
    
    func updateFirstname(firstname:String?) {
        firstname_new = firstname
    }
    
    func updateLastname(lastname:String?) {
        lastname_new = lastname
    }
    
    func updateBio(bio:String?) {
        description_new = bio
    }
    
    func updateEmail(email:String?) {
        email_new = email
    }
    
    func updateBirthDate(birthdate:String?) {
        birth_date_new = birthdate
    }
    
    func showSelectLocation() {
        let sb = UIStoryboard.init(name: "ProfileParams", bundle: nil)
        
        if let vc = sb.instantiateViewController(withIdentifier: "place_choose_vc") as? ParamsChoosePlaceViewController {
            vc.placeVCDelegate = self
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func updateRadius(radius:Int) {
        self.radius_new = radius
    }
}

//MARK: - PlaceViewControllerDelegate -
extension ProfileEditorViewController: PlaceViewControllerDelegate {
    func modifyPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        self.location_name_new = currentLocationName
        self.location_new = currentlocation
        self.location_googlePlace_new = googlePlace
        DispatchQueue.main.async {
            self.ui_tableview.reloadData()
        }
    }
}

//MARK: - EditProfilePhotoDelegate -
extension ProfileEditorViewController:EditProfilePhotoDelegate {
    func takeUserPhoto() {
        let sb = UIStoryboard(name: "ProfileParams", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "editProfilePhotoNav")
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
}

//MARK: - MJNavBackViewDelegate -
extension ProfileEditorViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}
