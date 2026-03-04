//
//  EventReservedFemaleCell.swift
//  entourage
//
//

import UIKit

protocol EventReservedFemaleCellDelegate: AnyObject {
    func updateReservedFemale(isReserved: Bool)
}

class EventReservedFemaleCell: UITableViewCell {

    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_switch: UISwitch!

    weak var delegate: EventReservedFemaleCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_title.text = "event_create_reserved_female_title".localized

        ui_switch.onTintColor = .appOrange
    }

    func populateCell(isReserved: Bool, delegate: EventReservedFemaleCellDelegate) {
        self.delegate = delegate
        ui_switch.isOn = isReserved
    }

    @IBAction func action_switch(_ sender: UISwitch) {
        delegate?.updateReservedFemale(isReserved: sender.isOn)
    }
}
