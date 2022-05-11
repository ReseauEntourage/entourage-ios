//
//  NeighborhoodParamSignalCell.swift
//  entourage
//
//  Created by Jerome on 02/05/2022.
//

import UIKit

class NeighborhoodParamSignalCell: UITableViewCell {

    @IBOutlet weak var ui_title: UILabel!
    
    weak var delegate:NeighborhoodParamCellDelegate? = nil
    
    var isQuit = false
    
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
