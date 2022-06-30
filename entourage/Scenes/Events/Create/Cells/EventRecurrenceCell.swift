//
//  EventRecurrenceCell.swift
//  entourage
//
//  Created by Jerome on 24/06/2022.
//

import UIKit

class EventRecurrenceCell: UITableViewCell {

    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet var ui_titles: [UILabel]!
    @IBOutlet var ui_image_buttons: [UIImageView]!
    
    weak var delegate:EventCreateDateCellDelegate? = nil
    
    private var selectedItem = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        changeSelection()
        
        var i = 1
        for title in ui_titles {
            switch i {
            case 1:
                title.text = "recurrence_once".localized
            case 2:
                title.text = "recurrence_week".localized
            case 3:
                title.text = "recurrence_every2Weeks".localized
            case 4:
                title.text = "recurrence_month".localized
            default:
                break
            }
            
            i = i + 1
        }
        let stringAttr = Utils.formatString(messageTxt: "event_create_phase2_recurrence".localized, messageTxtHighlight: "event_create_mandatory".localized, fontColorType: ApplicationTheme.getFontH2Noir(size: 15), fontColorTypeHighlight: ApplicationTheme.getFontLegend(size: 13))
        ui_title.attributedText = stringAttr
    }

    func populateCell(recurrence:EventRecurrence, delegate:EventCreateDateCellDelegate?) {
        self.delegate = delegate
        self.selectedItem = recurrence.rawValue
        changeSelection()
    }
    
    @IBAction func action_select(_ sender: UIButton) {
        if selectedItem == sender.tag { return }
        
        selectedItem = sender.tag
       
        changeSelection()
        
        sendRecurrenceSelected(pos: sender.tag)
    }
    
    private func sendRecurrenceSelected(pos:Int) {
        var recurrence = EventRecurrence.once
        switch pos {
        case 1:
            recurrence = .once
        case 2:
            recurrence = .week
        case 3:
            recurrence = .every2Weeks
        case 4:
            recurrence = .month
        default:
            break
        }
        
        delegate?.addRecurrence(recurrence: recurrence)
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
