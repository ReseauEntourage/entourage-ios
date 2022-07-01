//
//  EventPlaceCell.swift
//  entourage
//
//  Created by Jerome on 27/06/2022.
//

import UIKit

class EventPlaceCell: UITableViewCell {

    @IBOutlet weak var ui_title: UILabel!
    
    
    @IBOutlet weak var ui_view_place: UIView!
    @IBOutlet weak var ui_place_title: UILabel!
    @IBOutlet weak var ui_place_label: UILabel!
    @IBOutlet weak var ui_view_place_error: MJErrorInputTextView!
    
    @IBOutlet weak var ui_view_online: UIView!
    @IBOutlet weak var ui_online_title: UILabel!
    
    @IBOutlet weak var ui_online_tf: UITextField!
    @IBOutlet weak var ui_view_online_error: MJErrorInputTextView!
    
    
    @IBOutlet var ui_image_buttons: [UIImageView]!
    
    @IBOutlet var ui_title_buttons: [UILabel]!
    
    var selectedItem = 1
    
    weak var delegate:EventCreateLocationCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let stringAttr = Utils.formatString(messageTxt: "event_create_phase3_title".localized, messageTxtHighlight: "event_create_mandatory".localized, fontColorType: ApplicationTheme.getFontH2Noir(size: 15), fontColorTypeHighlight: ApplicationTheme.getFontLegend(size: 13))
        
        ui_title.attributedText = stringAttr
        
        let stringPlaceAttr = Utils.formatString(messageTxt: "event_create_phase3_title_place".localized, messageTxtHighlight: "event_create_mandatory".localized, fontColorType: ApplicationTheme.getFontH2Noir(size: 15), fontColorTypeHighlight: ApplicationTheme.getFontLegend(size: 13))
        
        ui_place_title.attributedText = stringPlaceAttr
        
        let stringOnlineAttr = Utils.formatString(messageTxt: "event_create_phase3_title_online".localized, messageTxtHighlight: "event_create_mandatory".localized, fontColorType: ApplicationTheme.getFontH2Noir(size: 15), fontColorTypeHighlight: ApplicationTheme.getFontLegend(size: 13))
        ui_online_title.attributedText = stringOnlineAttr
        
        ui_title_buttons[0].text = "event_create_phase3_presentiel".localized
        ui_title_buttons[1].text = "event_create_phase3_online".localized
        
        ui_place_label.text = "event_create_phase3_placeholder_place".localized
        ui_place_label.setupFontAndColor(style:  ApplicationTheme.getFontChampDefault(size: 13))
        
        ui_online_tf.setupFontAndColor(style: ApplicationTheme.getFontChampInput(size: 13, color: .black))
        ui_online_tf.placeholder = "event_create_phase3_placeholder_online".localized
        
        ui_view_place_error.isHidden = true
        ui_view_online_error.isHidden = true
        
        changeSelection()
        
        ui_online_tf.delegate = self
    }

    func populateCell(delegate:EventCreateLocationCellDelegate, showError:Bool, cityName:String?, urlOnline:String?, isOnline:Bool) {
        self.delegate = delegate
        ui_view_place_error.isHidden = !showError
        ui_view_online_error.isHidden = !showError
        
        selectedItem = isOnline ? 2 : 1
        
        if let cityName = cityName {
            ui_place_label.text = cityName
            ui_place_label.textColor = .black
        }
        else {
            ui_place_label.text = "event_create_phase3_placeholder_place".localized
            ui_place_label.textColor = .appGrisSombre40
        }
        
        ui_online_tf.text = urlOnline
        
        changeSelection()
    }
    
    @IBAction func action_select(_ sender: UIButton) {
        if selectedItem == sender.tag { return }
        
        selectedItem = sender.tag
       
        let isOnline = selectedItem == 2
        
        delegate?.resetPlaceOnlineSelection(isOnline: isOnline)
        
        changeSelection()
    }

    @IBAction func action_show_place(_ sender: Any) {
        delegate?.showSelectLocation()
    }
    
    private func changeSelection() {
        var i = 1
        for title in ui_title_buttons {
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
        
        if selectedItem == 1 {
            ui_view_place.isHidden = false
            ui_view_online.isHidden = true
        }
        else {
            ui_view_place.isHidden = true
            ui_view_online.isHidden = false
        }
    }
}
//MARK: - UITextFieldDelegate -
extension EventPlaceCell: UITextFieldDelegate {
    func checkErrorInput() -> Bool {
        var returnValidate = true
        if  ui_online_tf.text?.count ?? 0 >= ApplicationTheme.minHttpChars {
            self.ui_view_online_error.isHidden = true
        }
        else {
            ui_view_online_error.isHidden = false
            returnValidate = false
        }
        
        ui_online_tf.resignFirstResponder()
        delegate?.addOnlineUrl(urlOnline: ui_online_tf.text)
        return returnValidate
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ui_online_tf.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        _ = checkErrorInput()
        return true
    }
}

//MARK: - Protocol EventCreateLocationCellDelegate -
protocol EventCreateLocationCellDelegate:AnyObject {
    func showSelectLocation()
    func addOnlineUrl(urlOnline:String?)
    func resetPlaceOnlineSelection(isOnline:Bool)
    func addPlaceLimit(hasPlaceLimit:Bool, limitNb:Int)
}
