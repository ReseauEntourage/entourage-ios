//
//  QcmCell.swift
//  entourage
//
//  Created by Clement entourage on 14/03/2024.
//

import Foundation
import UIKit

protocol QcmCellDelegate{
    func onSwitchChanged(isQCM:Bool)
}

class QcmCell: UITableViewCell {
    
    // OUTLET
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_switch: UISwitch!
    
    // VAR
    var delegate: QcmCellDelegate? = nil
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Configurer l'observateur d'événement pour l'interrupteur
        ui_switch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    // Méthode appelée lorsque la valeur de l'interrupteur change
    @objc func switchValueChanged(_ uiSwitch: UISwitch) {
        // Appeler onValidate sur le délégué
        delegate?.onSwitchChanged(isQCM: uiSwitch.isOn)
    }
    
    func configure() {
        // Tu peux ajouter ici la configuration initiale de ta cellule si nécessaire
    }
}
