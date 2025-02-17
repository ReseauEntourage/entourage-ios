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
    @IBOutlet weak var ui_img_asso: UIImageView!
    
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

        // 🔹 Téléphone avec conversion +33 → 06
        if let phoneText = user.phone?.trimmingCharacters(in: .whitespacesAndNewlines), !phoneText.isEmpty {
            ui_label_phone.text = convertPhoneNumber(from: phoneText)
        } else {
            ui_label_phone.text = "no_data_available".localized
        }
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

        if let _url = user.partner?.smallLogoUrl, let url = URL(string: _url) {
            ui_img_asso.sd_setImage(with: url, placeholderImage:UIImage.init(named: "logo_entourage")) //TODO: avoir un placeholder pour les assos ?
        }
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
    
    func convertPhoneNumber(from number: String) -> String {
        var formattedNumber = number
        
        // Transformation du +33 en 0
        if number.hasPrefix("+33") {
            formattedNumber = "0" + number.dropFirst(3)
        }
        
        // Suppression des espaces et formatage en groupes de 2 chiffres
        let digitsOnly = formattedNumber.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        
        // Vérification de la longueur du numéro pour éviter les erreurs
        guard digitsOnly.count == 10 else { return number }
        
        return stride(from: 0, to: digitsOnly.count, by: 2)
            .map { index -> String in
                let start = digitsOnly.index(digitsOnly.startIndex, offsetBy: index)
                let end = digitsOnly.index(start, offsetBy: 2, limitedBy: digitsOnly.endIndex) ?? digitsOnly.endIndex
                return String(digitsOnly[start..<end])
            }
            .joined(separator: " ")
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
