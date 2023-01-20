//
//  EventShareCell.swift
//  entourage
//
//  Created by Jerome on 29/06/2022.
//

import UIKit

class EventShareCell: UITableViewCell {

    @IBOutlet weak var ui_title: UILabel!
    
    
    @IBOutlet var ui_titles: [UILabel]!
    @IBOutlet var ui_image_buttons: [UIImageView]!
    
    weak var delegate:EventShareCellDelegate? = nil
    
    private var selectedItem = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_titles[0].text = "createEventNotShare".localized
        ui_titles[1].text = "createEventShare".localized
        
        changeSelection()
       
        ui_title.text = "event_create_phase5_desc".localized
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontLegend(size: 13))
    }

    func populateCell(isSharing:Bool, delegate:EventShareCellDelegate?) {
        self.delegate = delegate
        self.selectedItem = isSharing ? 2 : 1
        changeSelection()
    }
    
    @IBAction func action_select(_ sender: UIButton) {
        if selectedItem == sender.tag { return }
        
        selectedItem = sender.tag
       
        changeSelection()
        
        sendSelection(pos: sender.tag)
    }
    
    private func sendSelection(pos:Int) {
       
        delegate?.setSharing(pos == 2)
    }
    
    private func changeSelection() {
        var i = 1
        for title in ui_titles {
            if i == selectedItem {
                title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
            }
            else {
                title.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
            }
            i = i + 1
        }
        
        i = 1
        for button in ui_image_buttons {
            if i == selectedItem {
                button.image = UIImage.init(named: "ic_selector_on")
            }
            else {
                button.image = UIImage.init(named: "ic_selector_off")
            }
            i = i + 1
        }
    }
}

//MARK: - Protocol NeighborhoodCreateAddOtherDelegate -
protocol EventShareCellDelegate: AnyObject {
    func setSharing(_ isSharing:Bool)
}
