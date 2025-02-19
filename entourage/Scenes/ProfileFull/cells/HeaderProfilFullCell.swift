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

class HeaderProfilFullCell: UITableViewCell {
    
    // OUTLETS
    @IBOutlet weak var ui_label_name: UILabel!
    @IBOutlet weak var ui_label_city: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    @IBOutlet weak var ui_btn_modify: UIButton!
    @IBOutlet weak var ui_label_phone: UILabel!
    @IBOutlet weak var ui_label_mail: UILabel!
    @IBOutlet weak var ui_label_partner: UILabel!
    @IBOutlet weak var ui_label_role: UILabel!
    @IBOutlet weak var ui_stack_view: UIStackView!        // Contient les vues pour les rôles & le partenaire
    @IBOutlet weak var ui_view_amba: UIView!              // Vue contenant le label des rôles
    @IBOutlet weak var ui_view_partner: UIView!           // Vue contenant le partenaire
    @IBOutlet weak var ui_img_asso: UIImageView!
    @IBOutlet weak var ui_label_stackview: UIStackView!   // Contient les labels d'info
    
    // VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    var delegate: HeaderProfilFullCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureOrangeButton(ui_btn_modify, withTitle: "modify".localized)
        ui_label_name.setFontTitle(size: 15)
        ui_label_city.setFontBody(size: 15)
        ui_label_description.setFontBody(size: 15)
        ui_label_phone.setFontBody(size: 15)
        ui_label_mail.setFontBody(size: 15)
        
        self.ui_btn_modify.addTarget(self, action: #selector(onModifyClick), for: .touchUpInside)
        

        ui_btn_modify.setContentHuggingPriority(.required, for: .horizontal)
        ui_btn_modify.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // Pour la stack view qui contient les labels d'info, on souhaite que les labels prennent seulement l'espace nécessaire
        ui_label_stackview.distribution = .equalSpacing
        for case let label as UILabel in ui_label_stackview.arrangedSubviews {
            label.setContentHuggingPriority(.required, for: .horizontal)
        }
        
        // Pour la stack view des vues (rôles & partenaire), on configure la distribution et les priorités
        ui_stack_view.distribution = .fill
        ui_stack_view.alignment = .leading
        
        // Ces vues ne doivent prendre que l'espace nécessaire à leur contenu
        ui_view_amba.setContentHuggingPriority(.required, for: .horizontal)
        ui_view_partner.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    @objc func onModifyClick(){
        delegate?.onModifyClick()
    }
    
    func configure(user: User, isMe: Bool) {
        // Réinitialisation de la visibilité (utile en cas de réutilisation de la cellule)
        [ui_label_name, ui_label_city, ui_label_description, ui_label_phone, ui_label_mail, ui_label_partner, ui_label_role].forEach {
            $0?.isHidden = false
        }
        ui_stack_view.isHidden = false
        
        // 🔹 Nom d'affichage
        let displayName = user.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        if displayName.isEmpty {
            ui_label_name.isHidden = true
        } else {
            ui_label_name.text = displayName
        }
        
        // 🔹 Ville (adresse principale)
        let city = user.addressPrimary?.displayAddress ?? ""
        let radiusString = String(user.radiusDistance ?? 0)
        let fullAddress = city.isEmpty ? "" : "\(city) - \(radiusString) km"
        if city.isEmpty {
            ui_label_city.isHidden = true
        } else {
            ui_label_city.text = fullAddress
        }
        
        // 🔹 Description (about)
        let aboutText = user.about?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if aboutText.isEmpty {
            ui_label_description.isHidden = true
        } else {
            ui_label_description.text = aboutText
        }
        
        // 🔹 Téléphone avec conversion +33 → 0
        if let phoneText = user.phone?.trimmingCharacters(in: .whitespacesAndNewlines), !phoneText.isEmpty {
            ui_label_phone.text = convertPhoneNumber(from: phoneText)
        } else {
            ui_label_phone.isHidden = true
        }
        
        // 🔹 Email
        let emailText = user.email?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if emailText.isEmpty {
            ui_label_mail.isHidden = true
        } else {
            ui_label_mail.text = emailText
        }
        
        // Pour les profils autres que "moi", on masque téléphone et mail et on change le titre du bouton
        if !isMe {
            ui_label_phone.isHidden = true
            ui_label_mail.isHidden = true
            self.ui_btn_modify.setTitle("detail_user_send_message".localized, for: .normal)
        } else {
            self.ui_btn_modify.setTitle("modify".localized, for: .normal)
        }
        
        // 🔹 Partenaire / Organisation
        let partnerText = (user.partner?.name.trimmingCharacters(in: .whitespacesAndNewlines))
                          ?? (user.organization?.name.trimmingCharacters(in: .whitespacesAndNewlines))
                          ?? ""
        if partnerText.isEmpty {
            ui_view_partner.isHidden = true
        } else {
            ui_label_partner.text = partnerText
        }
        
        if let partnerLogoUrl = user.partner?.smallLogoUrl, let url = URL(string: partnerLogoUrl) {
            ui_img_asso.sd_setImage(with: url, placeholderImage: UIImage(named: "logo_entourage"))
        }
        
        // 🔹 Rôles (avec formatage "Admin • Membre")
        if let roles = user.roles, !roles.isEmpty {
            ui_label_role.text = roles.joined(separator: " • ")
        } else {
            ui_view_amba.isHidden = true
        }
        
        // Si aucune des deux vues (rôles ou partenaire) n'est visible, on masque la stack view
        if ui_stack_view.arrangedSubviews.allSatisfy({ $0.isHidden }) {
            ui_stack_view.isHidden = true
        }
    }
    
    func convertPhoneNumber(from number: String) -> String {
        var formattedNumber = number
        
        // Transformation du +33 en 0
        if number.hasPrefix("+33") {
            formattedNumber = "0" + number.dropFirst(3)
        }
        
        // Suppression des caractères non numériques
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
