//
//  EventParamNotifCell.swift
//  entourage
//
//  Created by Jerome on 25/07/2022.
//

import UIKit

class EventParamNotifCell: UITableViewCell {


    @IBOutlet weak var ui_title_notif: UILabel!
    @IBOutlet weak var ui_lb_all: UILabel!
    @IBOutlet weak var ui_lb_publications: UILabel!
    @IBOutlet weak var ui_lb_members: UILabel!
    
    @IBOutlet weak var ui_switch_all: UISwitch!
    @IBOutlet weak var ui_switch_publications: UISwitch!
    @IBOutlet weak var ui_switch_members: UISwitch!
    
    weak var delegate:EventParamCellDelegate? = nil
    

    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title_notif.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_lb_all.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_lb_members.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_lb_publications.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        ui_title_notif.text = "event_params_notif_title".localized
        ui_lb_all.text = "event_params_notif_all".localized
        ui_lb_publications.text = "event_params_notif_new_publications".localized
        ui_lb_members.text = "event_params_notif_new_members".localized
    }

    func populateCell(notif_all:Bool,notif_publications:Bool,notif_members:Bool, delegate:EventParamCellDelegate) {
        self.delegate = delegate
        ui_switch_all.setOn(notif_all, animated: true)
        ui_switch_publications.setOn(notif_publications, animated: true)
        ui_switch_members.setOn(notif_members, animated: true)
    }
    
    @IBAction func action_all(_ sender: UISwitch) {
        delegate?.editNotif(notifType: .All, isOn: sender.isOn)
    }
    @IBAction func action_publications(_ sender: UISwitch) {
        delegate?.editNotif(notifType: .Publications, isOn: sender.isOn)
    }
    @IBAction func action_members(_ sender: UISwitch) {
        delegate?.editNotif(notifType: .Members, isOn: sender.isOn)
    }
}
