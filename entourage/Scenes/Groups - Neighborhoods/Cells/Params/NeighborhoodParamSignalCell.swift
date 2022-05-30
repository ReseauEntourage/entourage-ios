//
//  NeighborhoodParamSignalCell.swift
//  entourage
//
//  Created by Jerome on 02/05/2022.
//

import UIKit

class NeighborhoodParamSignalCell: UITableViewCell {

    @IBOutlet weak var ui_title: UILabel!
    
    @IBOutlet weak var ui_constraint_title_bottom: NSLayoutConstraint!
    weak var delegate:NeighborhoodParamCellDelegate? = nil
    
    var isQuit = false
    let marginBottom:CGFloat = 20
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
        ui_title.text = ""
    }
    
    func populateCell(isQuit:Bool,delegate:NeighborhoodParamCellDelegate) {
        self.isQuit = isQuit
        self.delegate = delegate
        
        if isQuit {
            ui_title.text = "neighborhood_params_quit".localized
            ui_constraint_title_bottom.constant = marginBottom
        }
        else {
            ui_title.text = "neighborhood_params_signal".localized
        }
    }
    @IBAction func action_signal(_ sender: Any) {
        if isQuit {
            delegate?.quitGroup()
        }
        else {
            delegate?.signalGroup()
        }
    }
}
