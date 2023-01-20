//
//  NeighborhoodParamNotifsCell.swift
//  entourage
//
//  Created by Jerome on 11/05/2022.
//

import UIKit

class NeighborhoodParamNotifsCell: UITableViewCell {

    @IBOutlet weak var ui_title_notif: UILabel!
    @IBOutlet weak var ui_lb_all: UILabel!
    @IBOutlet weak var ui_lb_events: UILabel!
    @IBOutlet weak var ui_lb_messages: UILabel!
    @IBOutlet weak var ui_lb_members: UILabel!
    
    @IBOutlet weak var ui_switch_all: UISwitch!
    @IBOutlet weak var ui_switch_events: UISwitch!
    @IBOutlet weak var ui_switch_messages: UISwitch!
    @IBOutlet weak var ui_switch_members: UISwitch!
    
    weak var delegate:NeighborhoodParamCellDelegate? = nil
    

    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title_notif.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_lb_all.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_lb_events.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_lb_members.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_lb_messages.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        ui_title_notif.text = "neighborhood_params_notif_title".localized
        ui_lb_all.text = "neighborhood_params_notif_all".localized
        ui_lb_events.text = "neighborhood_params_notif_new_events".localized
        ui_lb_messages.text = "neighborhood_params_notif_new_messages".localized
        ui_lb_members.text = "neighborhood_params_notif_new_members".localized
    }

    func populateCell(notif_all:Bool,notif_events:Bool,notif_messages:Bool,notif_members:Bool, delegate:NeighborhoodParamCellDelegate) {
        self.delegate = delegate
        ui_switch_all.setOn(notif_all, animated: true)
        ui_switch_events.setOn(notif_events, animated: true)
        ui_switch_messages.setOn(notif_messages, animated: true)
        ui_switch_members.setOn(notif_members, animated: true)
    }
    
    @IBAction func action_all(_ sender: UISwitch) {
        delegate?.editNotif(notifType: .All, isOn: sender.isOn)
    }
    @IBAction func action_events(_ sender: UISwitch) {
        delegate?.editNotif(notifType: .Events, isOn: sender.isOn)
    }
    @IBAction func action_messages(_ sender: UISwitch) {
        delegate?.editNotif(notifType: .Messages, isOn: sender.isOn)
    }
    @IBAction func action_members(_ sender: UISwitch) {
        delegate?.editNotif(notifType: .Members, isOn: sender.isOn)
    }
    
}
