//
//  EventParamEditShow.swift
//  entourage
//
//  Created by Jerome on 25/07/2022.
//

import UIKit

class EventParamEditShow: UITableViewCell {

    @IBOutlet weak var ui_image_arrow: UIImageView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_separator: UIView!

    weak var delegate: EventParamCellDelegate? = nil

    var cellType: EventCellEditType = .CGU

    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontH2Noir())
    }

    func populateCell(
        title: String,
        imageName: String? = nil,
        showArrow: Bool = true,
        showSeparator: Bool = true,
        forceBlackIcon: Bool = false,
        delegate: EventParamCellDelegate,
        type: EventCellEditType
    ) {
        self.delegate = delegate
        self.cellType = type

        ui_image.tintColor = UIColor.black
        ui_title.text = title

        if let imageName = imageName {
            let image = UIImage(named: imageName)
            // Un asset en couleur (ex. l'icône orange partagée avec les groupes) ignore la teinte :
            // le rendu « template » la force en noir comme les autres lignes.
            ui_image.image = forceBlackIcon ? image?.withRenderingMode(.alwaysTemplate) : image
        }

        ui_image_arrow.isHidden = !showArrow
        ui_separator.isHidden = !showSeparator
    }

    @IBAction func action_show(_ sender: Any) {
        switch cellType {
        case .CGU:
            delegate?.showCGU()
        case .EditEvent:
            delegate?.editEvent()
        case .DuplicateEvent:
            delegate?.duplicateEvent()
        case .EditRecurrency:
            delegate?.editRecurrency()
        case .share:
            delegate?.share()
        case .showMembers:
            delegate?.showMembers()
        }
    }
}
