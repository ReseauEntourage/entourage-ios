//
//  EditProfileOnboardingCell.swift
//  entourage
//
//  Created by Clement entourage on 03/06/2024.
//

import Foundation

class EditProfileOnboardingCell:UITableViewCell{
    
    //Outlet
    @IBOutlet weak var ui_title: UILabel!
    
    //Variable
    
    override  func awakeFromNib() {
        ui_title.text = "edit_profile_cell_onboarding".localized
    }
}
