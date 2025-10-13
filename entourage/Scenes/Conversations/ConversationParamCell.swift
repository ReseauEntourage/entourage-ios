//
//  ConversationParamCell.swift
//  entourage
//
//  Created by Jerome on 26/08/2022.
//  MAJ 2025-10-13 : pictos forcés en template noir, sauf cas orange (signaler / quitter)
//

import UIKit

class ConversationParamCell: UITableViewCell {

    @IBOutlet weak var ui_picto: UIImageView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_subtitle: UILabel?
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_separator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_subtitle?.setupFontAndColor(style: ApplicationTheme.getFontChampDefault())
        ui_separator.isHidden = false
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        ui_title.text = nil
        ui_subtitle?.text = nil
        ui_picto.image = nil
        ui_picto.tintColor = .black
        ui_separator.isHidden = false
    }

    /// Configure la cellule avec gestion du picto template/tint.
    func populateCell(
        title: String,
        subtitle: String?,
        isTitleOrange: Bool,
        pictoStr: String,
        hideSeparator: Bool = false,
        isIconOrange: Bool = false // ✅ permet de forcer une icône orange
    ) {
        // Titre
        ui_title.text = title
        ui_title.textColor = isTitleOrange ? .appOrange : .black

        // Sous-titre
        if let st = subtitle, !st.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ui_subtitle?.text = st
            ui_subtitle?.isHidden = false
        } else {
            ui_subtitle?.isHidden = true
        }

        // Picto
        if let base = UIImage(named: pictoStr) {
            ui_picto.image = base.withRenderingMode(.alwaysTemplate)
            ui_picto.tintColor = isIconOrange ? .appOrange : .black
        } else {
            ui_picto.image = nil
        }

        // Séparateur
        ui_separator.isHidden = hideSeparator
    }
}
