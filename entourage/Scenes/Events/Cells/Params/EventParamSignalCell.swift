//
//  EventParamSignalCell.swift
//  entourage
//
//  Created by Jerome on 25/07/2022.
//

import UIKit

class EventParamSignalCell: UITableViewCell {

    @IBOutlet weak var ui_title: UILabel!
    
    @IBOutlet weak var ui_constraint_title_bottom: NSLayoutConstraint!
    weak var delegate:EventParamCellDelegate? = nil
    
    var isQuit = false
    let marginBottom:CGFloat = 20
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
        ui_title.text = ""
    }
    
    func populateCell(isQuit:Bool, hasCellBottom:Bool, delegate:EventParamCellDelegate, isCancelEvent:Bool) {
        self.isQuit = isQuit
        self.delegate = delegate
        
        if isQuit {
            ui_title.text = isCancelEvent ? "event_params_cancel".localized : "event_params_quit".localized
            ui_constraint_title_bottom.constant = marginBottom
        }
        else {
            if !hasCellBottom {
                ui_constraint_title_bottom.constant = marginBottom
            }
            ui_title.text = "event_params_signal".localized
        }
    }
    @IBAction func action_signal(_ sender: Any) {
        if isQuit {
            delegate?.quitEvent()
        }
        else {
            delegate?.signalEvent()
        }
    }
}
