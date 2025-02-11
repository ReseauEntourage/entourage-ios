//
//  HeaderProfilFullCell.swift
//  entourage
//
//  Created by Clement entourage on 10/01/2025.
//

import Foundation
import UIKit

protocol HeaderProfilFullCellDelegate {
    func onModifyClick()
}
class HeaderProfilFullCell:UITableViewCell {
    
    //OUTLET
    @IBOutlet weak var uiStackView: UIStackView!
    @IBOutlet weak var ui_label_name: UILabel!
    @IBOutlet weak var ui_label_city: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    @IBOutlet weak var ui_btn_modify: UIButton!
    @IBOutlet weak var ui_label_phone: UILabel!
    @IBOutlet weak var ui_label_mail: UILabel!
    @IBOutlet weak var ui_label_partner: UILabel!
    @IBOutlet weak var ui_label_role: UILabel!
    @IBOutlet weak var ui_stack_view: UIStackView!
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    var delegate:HeaderProfilFullCellDelegate?
    
    override func awakeFromNib() {
        configureOrangeButton(ui_btn_modify, withTitle: "modify".localized)
        ui_label_name.setFontTitle(size: 15)
        ui_label_city.setFontBody(size: 15)
        ui_label_description.setFontBody(size: 15)
        ui_label_phone.setFontBody(size: 15)
        ui_label_mail.setFontBody(size: 15)
        
        self.ui_btn_modify.addTarget(self, action: #selector(onModifyClick), for: .touchUpInside)
    }
    
    @objc func onModifyClick(){
        delegate?.onModifyClick()
    }
    
    func configure(user: User, isMe:Bool) {
        // 🔹 Nom d'affichage
        let displayName = user.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        ui_label_name.text = displayName.isEmpty ? nil : displayName
        if displayName.isEmpty { ui_label_name.text = "no_data_available".localized }

        // 🔹 Ville (adresse principale)
        let city = user.addressPrimary?.displayAddress ?? ""
        let radiusString = String(user.radiusDistance ?? 0)
        let full_address = city + " - " +  radiusString + " km"
        ui_label_city.text = full_address
        if city.isEmpty { ui_label_city.text = "no_data_available".localized  }

        // 🔹 Description (about)
        let aboutText = user.about?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        ui_label_description.text = aboutText.isEmpty ? nil : aboutText
        if aboutText.isEmpty { ui_label_description.text = "no_data_available".localized }

        // 🔹 Téléphone
        let phoneText = user.phone?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        ui_label_phone.text = phoneText.isEmpty ? nil : phoneText
        if phoneText.isEmpty { ui_label_phone.text = "no_data_available".localized }

        // 🔹 Email
        let emailText = user.email?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        ui_label_mail.text = emailText.isEmpty ? nil : emailText
        if emailText.isEmpty { ui_label_mail.text = "no_data_available".localized }
        
        if !isMe {
            ui_label_phone.setVisibilityGone()
            ui_label_mail.setVisibilityGone()
            self.ui_btn_modify.setTitle("detail_user_send_message".localized, for: .normal)
        }else{
            self.ui_btn_modify.setTitle("modify".localized, for: .normal)
        }

        // 🔹 Partenaire / Organisation
        let partnerText = user.partner?.name.trimmingCharacters(in: .whitespacesAndNewlines) ??
                          user.organization?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        ui_label_partner.text = partnerText.isEmpty ? nil : partnerText
        if partnerText.isEmpty { ui_label_partner.text = "no_data_available".localized }

        // 🔹 Rôles (avec formatage "Admin • Membre")
        let hasRoles = (user.roles?.isEmpty == false)
        ui_label_role.text = hasRoles ? user.roles!.joined(separator: " • ") : nil
        if !hasRoles { ui_label_role.setVisibilityGone() }

        // 🔹 Gestion des vues dans la StackView
        if let firstView = ui_stack_view.arrangedSubviews.first, let secondView = ui_stack_view.arrangedSubviews.last {
            if !hasRoles { firstView.setVisibilityGone() }  // Cache la 1ʳᵉ vue si pas de rôle
            if partnerText.isEmpty { secondView.setVisibilityGone() }  // Cache la 2ᵉ vue si pas de partenaire

            // Si les deux sous-vues sont cachées, cacher toute la StackView
            if firstView.isHidden && secondView.isHidden {
                ui_stack_view.setVisibilityGone()
            }
        }
    }


    
    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }
    

    
}
