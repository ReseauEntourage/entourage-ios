import UIKit
import CoreLocation
import GooglePlaces
import SVProgressHUD

class ProfileEditorViewController: UIViewController {
    
    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_error_view: MJErrorInputView!
    @IBOutlet weak var ui_button_validate: UIButton!
    @IBOutlet weak var ui_tableview: UITableView!
    
    var currentUser: User? = nil
    var firstname_new: String? = nil
    var lastname_new: String? = nil
    var description_new: String? = nil
    var birth_date_new: String? = nil
    var email_new: String? = nil
    var radius_new: Int? = nil
    var gender_new: String? = nil
    var profilFullDelegate: ImageReUpLoadDelegate?
    var location_new: CLLocationCoordinate2D? = nil
    var location_name_new: String? = nil
    var location_googlePlace_new: GMSPlace? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if currentUser == nil {
            currentUser = UserDefaults.currentUser
        }
        
        setupUI()
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePhotoUser), name: NSNotification.Name(kNotificationProfilePictureUpdated), object: nil)
    }
    
    private func setupUI() {
        ui_top_view.populateView(title: "editUserProfileTitle".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self)
        
        ui_button_validate.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 18)
        ui_button_validate.layer.cornerRadius = ui_button_validate.frame.height / 2
        configureOrangeButton(ui_button_validate, withTitle: "editUserProfileValidate".localized)
        
        ui_error_view.populateView(backgroundColor: .white.withAlphaComponent(0.6))
        ui_error_view.hide()
        
        self.modalPresentationStyle = .fullScreen
    }

    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }

    // MARK: - Keyboard Management
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        ui_tableview.contentInset = contentInsets
        ui_tableview.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        ui_tableview.contentInset = contentInsets
        ui_tableview.scrollIndicatorInsets = contentInsets
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - IBActions
    @IBAction func action_validate(_ sender: Any) {
        self.validateProfile()
    }
    
    @IBAction func action_close(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
    
    // MARK: - Methods
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
        
        // Validation Prénom
        if let fname = firstname_new {
            if fname.count >= ApplicationTheme.minfirstnameChars { newUser?.firstname = fname }
            else { showError(message: "editUser_error_firstname".localized); return }
        }
        
        // Validation Nom
        if let lname = lastname_new {
            if lname.count >= ApplicationTheme.minLastnameChars { newUser?.lastname = lname }
            else { showError(message: "editUser_error_lastname".localized); return }
        }
        
        // Validation Bio
        if let bio = description_new, bio.count > 0 {
            if bio.count > 2 { newUser?.about = bio }
            else { showError(message: "editUser_error_bio".localized); return }
        } else if description_new != nil {
            newUser?.about = ""
        }
        
        // Validation Email
        if let email = email_new, email.count > 0 {
            if email.isValidEmail { newUser?.email = email }
            else { showError(message: "editUser_error_email".localized); return }
        }
        
        // VALIDATION DATE DE NAISSANCE (Correction de la Regex ici)
        if let bdate = birth_date_new, bdate.count > 0 {
            let regex = #"^([0-2][0-9]|(3)[0-1])(/)(((0)[0-9])|((1)[0-2]))(/)\d{4}$"#
            if bdate.matchesRegEx(regex) {
                let dateFormat = DateFormatter()
                dateFormat.locale = Locale(identifier: "fr_FR")
                dateFormat.dateFormat = "dd/MM/yyyy"
                if let _date = dateFormat.date(from: bdate) {
                    dateFormat.dateFormat = "yyyy-MM-dd"
                    newUser?.birthdate = dateFormat.string(from: _date)
                } else {
                    showError(message: "editUser_error_birthday".localized); return
                }
            } else {
                showError(message: "editUser_error_birthday".localized); return
            }
        } else if !(currentUser?.birthdate?.count ?? 0 > 0) {
            newUser?.birthdate = ""
        }
        
        if let radius = radius_new { newUser?.radiusDistance = radius }
        if let gender = gender_new { newUser?.gender = gender }

        // Gestion Localisation
        if let gplace = location_googlePlace_new, let placeId = gplace.placeID {
            UserService.updateUserAddressWith(placeId: placeId, isSecondaryAddress: false) { _ in
                self.location_googlePlace_new = nil
                self.updateUser()
            }
        } else if let loc = location_new, let locName = location_name_new {
            UserService.updateUserAddressWith(name: locName, latitude: loc.latitude, longitude: loc.longitude, isSecondaryAddress: false) { _ in
                self.location_name_new = nil
                self.location_new = nil
                self.updateUser()
            }
        }
        
        SVProgressHUD.show()
        UserService.updateUser(user: newUser, isOnboarding: false) { _, error in
            SVProgressHUD.dismiss()
            if error?.error != nil {
                self.ui_tableview.reloadData()
                return
            }
            self.profilFullDelegate?.reloadOnImageUpdate()
            self.dismiss(animated: true)
        }
    }
    
    private func showError(message: String, imageName: String? = nil) {
        ui_error_view.changeTitleAndImage(title: message, imageName: imageName)
        ui_error_view.show()
    }
}

// MARK: - Tableview Datasource / Delegate
extension ProfileEditorViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 // Corrigé de 3 à 4 pour inclure toutes les cellules
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPhoto", for: indexPath) as! EditProfilePhotoCell
            cell.populateCell(photoUrl: currentUser?.avatarURL, delegate: self)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EditProfileInfosCell
            var cityName = location_name_new ?? location_googlePlace_new?.formattedAddress ?? currentUser?.addressPrimary?.displayAddress
            cell.populateCell(firstname: currentUser?.firstname, lastname: currentUser?.lastname, bio: currentUser?.about, birthdate: currentUser?.birthdate, email: currentUser?.email, phone: currentUser?.phone, cityName: cityName, radius: currentUser?.radiusDistance, gender: currentUser?.gender, delegate: self)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellInterests", for: indexPath)
            cell.contentView.isHidden = false // Remis à false pour être visible
            return cell
        case 3:
            return tableView.dequeueReusableCell(withIdentifier: "cellOnboarding", for: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "EnhancedOnboarding", bundle: nil)
        let config = EnhancedOnboardingConfiguration.shared
        
        if indexPath.row == 2 {
            config.isInterestsFromSetting = true
            if let vc = storyboard.instantiateViewController(withIdentifier: "enhancedOnboarding") as? EnhancedViewController {
                vc.modalPresentationStyle = .fullScreen
                vc.mode = .interest
                present(vc, animated: true)
            }
        } else if indexPath.row == 3 {
            config.isOnboardingFromSetting = true
            if let vc = storyboard.instantiateViewController(withIdentifier: "enhancedOnboardingIntro") as? EnhancedOnboardingIntro {
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
        }
    }
}

// MARK: - CellTextDelegate
extension ProfileEditorViewController: CellTextDelegate {
    func updateCellHeight() {
        DispatchQueue.main.async {
            self.ui_tableview?.beginUpdates()
            self.ui_tableview?.endUpdates()
        }
    }
    
    func updateFirstname(firstname: String?) { firstname_new = firstname }
    func updateLastname(lastname: String?) { lastname_new = lastname }
    func updateBio(bio: String?) { description_new = bio }
    func updateEmail(email: String?) { email_new = email }
    func updateBirthDate(birthdate: String?) { birth_date_new = birthdate }
    func updateRadius(radius: Int) { self.radius_new = radius }
    func updateGender(gender: String?) { self.gender_new = gender }
    
    func showSelectLocation() {
        let sb = UIStoryboard(name: StoryboardName.profileParams, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "place_choose_vc") as? ParamsChoosePlaceViewController {
            vc.placeVCDelegate = self
            self.navigationController?.present(vc, animated: true)
        }
    }
}

// MARK: - PlaceViewControllerDelegate
extension ProfileEditorViewController: PlaceViewControllerDelegate {
    func modifyPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        self.location_name_new = currentLocationName
        self.location_new = currentlocation
        self.location_googlePlace_new = googlePlace
        self.updateUser()
    }
}

// MARK: - EditProfilePhotoDelegate / MJNavBackViewDelegate
extension ProfileEditorViewController: EditProfilePhotoDelegate, MJNavBackViewDelegate {
    func takeUserPhoto() {
        let sb = UIStoryboard(name: StoryboardName.profileParams, bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "editProfilePhotoNav")
        self.navigationController?.present(vc, animated: true)
    }
    
    func goBack() { self.navigationController?.dismiss(animated: true) }
    func didTapEvent() { }
}
