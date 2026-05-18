//
//  InterestsCollectionViewCell.swift
//  entourage
//
//  Created by Clement entourage on 31/05/2024.
//

import Foundation
import UIKit

class InterestsCollectionViewCell:UICollectionViewCell{
    
    //Outlet
    @IBOutlet weak var ui_image_choice: UIImageView!
    
    @IBOutlet weak var ui_image_check: UIImageView!
    
    @IBOutlet weak var ui_title_label: UILabel!
    @IBOutlet weak var ui_subtitle_label: UILabel!
    @IBOutlet weak var ui_container_view: UIView!
    //Variable
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.ui_container_view.layer.borderWidth = 1
        self.ui_image_choice.backgroundColor = UIColor.appBeige
        self.ui_image_choice.layer.cornerRadius = 30
    }
    
    func configure(choice:OnboardingChoice, isSelected:Bool){
        print("choice : ", choice.title)
        self.ui_title_label.text = choice.title

        if let sub = choice.subtitle, !sub.trimmingCharacters(in: .whitespaces).isEmpty {
            self.ui_subtitle_label?.text = sub
            self.ui_subtitle_label?.isHidden = false
        } else {
            self.ui_subtitle_label?.isHidden = true
            self.ui_subtitle_label?.text = ""
        }

        self.ui_image_choice.image = UIImage(named: choice.img)
        if isSelected {
            ui_image_check.image = UIImage(named: "ic_onboarding_checked")
            self.ui_container_view.layer.borderColor = UIColor.appOrangeLight.cgColor
            self.ui_container_view.backgroundColor = UIColor(red: 255/255, green: 245/255, blue: 235/255, alpha: 0.5)
        }else{
            ui_image_check.image = UIImage(named: "ic_onboarding_unchecked")
            self.ui_container_view.layer.borderColor = UIColor.appGrey151.cgColor
            self.ui_container_view.backgroundColor = .clear

        }
    }
    
}
