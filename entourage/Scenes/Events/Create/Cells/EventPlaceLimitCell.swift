//
//  EventPlaceLimitCell.swift
//  entourage
//
//  Created by Jerome on 27/06/2022.
//

import UIKit

class EventPlaceLimitCell: UITableViewCell {
    
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_view_limit: UIView!
    @IBOutlet weak var ui_limit_title: UILabel!
    @IBOutlet weak var ui_limit_tf: UITextField!
    @IBOutlet weak var ui_view_error: MJErrorInputTextView!
    
    @IBOutlet var ui_title_buttons: [UILabel]!
    @IBOutlet var ui_image_buttons: [UIImageView]!
    
    var selectedItem = 2
    
    weak var delegate:EventCreateLocationCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let stringAttr = Utils.formatString(messageTxt: "event_create_phase3_title_limit".localized, messageTxtHighlight: "event_create_mandatory".localized, fontColorType: ApplicationTheme.getFontH2Noir(size: 15), fontColorTypeHighlight: ApplicationTheme.getFontLegend(size: 13))
        let stringAttrLimit = Utils.formatString(messageTxt: "event_create_phase3_title_nb_places".localized, messageTxtHighlight: "event_create_mandatory".localized, fontColorType: ApplicationTheme.getFontH2Noir(size: 15), fontColorTypeHighlight: ApplicationTheme.getFontLegend(size: 13))
        
        ui_title.attributedText = stringAttr
        
        ui_limit_title.attributedText = stringAttrLimit
        
        ui_title_buttons[0].text = "event_create_phase3_limit_yes".localized
        ui_title_buttons[1].text = "event_create_phase3_limit_no".localized
        ui_view_error.isHidden = true
        ui_view_error.setupView(title: "event_create_phase3_limit_error".localized, imageName: nil)
        
        ui_limit_tf.setupFontAndColor(style: ApplicationTheme.getFontChampDefault(size: 13,color: .black))
        ui_limit_tf.placeholder = "event_create_phase3_title_nb_places_placeholder".localized
        ui_limit_tf.delegate = self
        
        let _width = UIApplication.shared.delegate?.window??.frame.width ?? contentView.frame.size.width
        let buttonDone = UIBarButtonItem(title: "validate".localized, style: .plain, target: self, action: #selector(closeKb(_:)))
        ui_limit_tf.addToolBar(width: _width, buttonValidate: buttonDone)
        
        changeSelection()
    }
    
    func populateCell(delegate:EventCreateLocationCellDelegate, hasPlaceLimit:Bool, limitNb:Int) {
        self.delegate = delegate
        
        selectedItem = hasPlaceLimit ? 1 : 2
        
        changeSelection()
        
        ui_limit_tf.text = ""
        if limitNb > 0 {
            ui_limit_tf.text = "\(limitNb)"
        }
    }
    
    @IBAction func action_select(_ sender: UIButton) {
        if selectedItem == sender.tag { return }
        
        selectedItem = sender.tag
        
        changeSelection()
        
        delegate?.addPlaceLimit(hasPlaceLimit: selectedItem == 1, limitNb: 0)
    }
    
    @objc func closeKb(_ sender:UIBarButtonItem?) {
        _ = checkErrorInput()
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
            ui_limit_tf.text = ""
            ui_view_limit.isHidden = false
        }
        else {
            ui_view_limit.isHidden = true
        }
    }
    
}
//MARK: - UITextFieldDelegate -
extension EventPlaceLimitCell: UITextFieldDelegate {
    func checkErrorInput() -> Bool {
        var returnValidate = true
        if  ui_limit_tf.text?.count ?? 0 >= 1 {
            self.ui_view_error.isHidden = true
        }
        else {
            ui_view_error.isHidden = false
            returnValidate = false
        }
        
        ui_limit_tf.resignFirstResponder()
        let _limit:Int = Int(ui_limit_tf.text!) ?? 0
        delegate?.addPlaceLimit(hasPlaceLimit: true, limitNb: _limit)
        return returnValidate
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ui_limit_tf.resignFirstResponder()
        _ = checkErrorInput()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
