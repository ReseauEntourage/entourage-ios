//
//  ProfileEditInterestsViewController.swift
//  entourage
//
//  Created by Jerome on 24/03/2022.
//

import UIKit

class ProfileEditInterestsViewController: UIViewController {
    
    @IBOutlet weak var ui_lbl_info: UILabel!
    @IBOutlet weak var ui_error_view: MJErrorInputView!
    @IBOutlet weak var ui_button_validate: UIButton!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_tableview: UITableView!
    
    var currentUser:User? = nil
    var tagsInterests:TagsInterests! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = UserDefaults.currentUser
        
        ui_top_view.populateView(title: "editUserInterestsTitle".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self)
        
        self.ui_lbl_info.font = ApplicationTheme.getFontTextRegular().font
        self.ui_lbl_info.textColor = ApplicationTheme.getFontTextRegular().color
        
        ui_lbl_info.text = "editUserInterestsInfo".localized
        
        ui_button_validate.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 18)
        ui_button_validate.titleLabel?.textColor = .white
        ui_button_validate.layer.cornerRadius = ui_button_validate.frame.height / 2
        ui_button_validate.setTitle("editUserInterestsValidate".localized, for: .normal)
        
        //TODO: on affiche le fond transparent pour l'alerte ou un fond blanc ?
        ui_error_view.populateView(backgroundColor: .white.withAlphaComponent(0.6))
        ui_error_view.hide()
        
        if let interests = currentUser?.interests {
            for interest in interests {
                Logger.print("***** inside prodiedit interests : \(interest)")
                if let _ = tagsInterests?.getTagInterestName(key: interest) {
                    Logger.print("***** inside prodiedit interests found: \(interest)")
                    tagsInterests?.checkUncheckInterestFrom(key: interest, isCheck: true)
                }
            }
        }
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tagsInterests = tagsInterests, tagsInterests.getInterests().count > 0 else {
            self.dismiss(animated: true)
            return
        }
        
        super.viewWillAppear(animated)
    }
    
    @IBAction func action_validate(_ sender: Any) {
        var hasOneCheck = false
        
        for interest in tagsInterests.getInterests() {
            if interest.isSelected {
                hasOneCheck = true
                break
            }
        }
        
        if hasOneCheck {
            updateInterests()
        }
        else {
            showError(message: "editUserInterests_error".localized)
        }
    }
    
    func updateInterests() {
        UserService.updateUserInterests(interests: tagsInterests.getInterestsForWS()) { user, error in
            Logger.print("Return update Interests : \(user)")
            if let err = error?.error {
                self.showError(message: err.localizedDescription)
                return
            }
            
            self.dismiss(animated: true)
        }
    }
    
    func showError(message:String) {
        ui_error_view.changeTitleAndImage(title: message)
        ui_error_view.show()
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate  -
extension ProfileEditInterestsViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagsInterests?.getInterests().count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellInterest", for: indexPath) as! EditProfileInterestCell
        
        let interest = tagsInterests?.getInterests()[indexPath.row]
        
        
        cell.populateCell(title: tagsInterests!.getTagInterestName(key: interest!.name) , isChecked: interest!.isSelected, imageName: interest!.tagImageName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isCheck = tagsInterests!.getInterests()[indexPath.row].isSelected
        
        tagsInterests?.checkUncheckInterestFrom(position: indexPath.row, isCheck: !isCheck)
        tableView.reloadData()
    }
}

//MARK: - MJNavBackViewDelegate -
extension ProfileEditInterestsViewController: MJNavBackViewDelegate {
    func goBack() {
        self.dismiss(animated: true)
    }
}
