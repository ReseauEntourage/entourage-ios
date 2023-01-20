//
//  OnboardingEndCell.swift
//  entourage
//
//  Created by You on 02/12/2022.
//

import UIKit

class OnboardingEndCell: UITableViewCell {

    
    @IBOutlet weak var ui_description: UILabel!
    
    @IBOutlet weak var ui_view_entour: UIView!
    @IBOutlet weak var ui_view_beentour: UIView!
    
    @IBOutlet weak var ui_check_entour: UIImageView!
    @IBOutlet weak var ui_title_entour: UILabel!
    @IBOutlet weak var ui_desc_entour: UILabel!
    
    @IBOutlet weak var ui_check_beentour: UIImageView!
    @IBOutlet weak var ui_title_beentour: UILabel!
    @IBOutlet weak var ui_desc_beentour: UILabel!
    
    
    @IBOutlet weak var ui_title_place: UILabel!
    @IBOutlet weak var ui_desc_place: UILabel!
    
    @IBOutlet weak var ui_desc_info_place: UILabel!
    
    @IBOutlet weak var ui_title_asso: UILabel!
    @IBOutlet weak var ui_check_asso: UIImageView!
    @IBOutlet weak var ui_view_asso: UIView!
    
    
    
    var isEntourCheck = false
    var isBeEntourCheck = false
    var isAssoCheck = false
    
    weak var delegate:OnboardingEndCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_description.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 17))
        ui_title_entour.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 17))
        ui_desc_entour.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 15))
        ui_title_beentour.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 17))
        ui_desc_beentour.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 15))
        ui_title_place.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 17))
        ui_desc_place.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 15))
        ui_desc_info_place.setupFontAndColor(style: ApplicationTheme.getFontLegend(size: 13))
        
        ui_view_entour.layer.borderWidth = 1
        ui_view_entour.layer.borderColor = UIColor.appOrange.cgColor
        ui_view_entour.layer.cornerRadius = 20
        
        ui_view_beentour.layer.borderWidth = 1
        ui_view_beentour.layer.borderColor = UIColor.appOrange.cgColor
        ui_view_beentour.layer.cornerRadius = 20
        
        ui_desc_place.text = "onboard_phase3_title".localized
        ui_title_entour.text = "onboard_title_entour".localized
        ui_desc_entour.text = "onboard_subtitle_entour".localized
        ui_title_beentour.text = "onboard_title_beentour".localized
        ui_desc_beentour.text = "onboard_subtitle_beentour".localized
        ui_title_place.text = "onboard_place_title_new".localized
        ui_desc_place.text = "onboard_place_infos_placeholder".localized
        ui_desc_info_place.text = "onboard_place_desc".localized
        
        ui_title_asso.text = "onboard_info_asso".localized
        ui_title_asso.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularOrange(size: 14))
        ui_view_asso.layer.borderWidth = 1
        ui_view_asso.layer.borderColor = UIColor.appOrange.cgColor
        ui_view_asso.layer.cornerRadius = ui_view_asso.frame.height / 2

        changeViewCheck()
    }
    
    
    private func changeViewCheck() {
        let iv_check = UIImage.init(named: "ic_selection_on")
        let iv_uncheck = UIImage.init(named: "ic_selection_off")
        
        if isEntourCheck {
            ui_check_entour.image = iv_check
            ui_view_entour.backgroundColor = .appBeige
        }
        else {
            ui_check_entour.image = iv_uncheck
            ui_view_entour.backgroundColor = .appBeigeClair
        }
        
        if isBeEntourCheck {
            ui_check_beentour.image = iv_check
            ui_view_beentour.backgroundColor = .appBeige
        }
        else {
            ui_check_beentour.image = iv_uncheck
            ui_view_beentour.backgroundColor = .appBeigeClair
        }
        if isAssoCheck {
            ui_check_asso.image = iv_check
        }
        else {
            ui_check_asso.image = iv_uncheck
        }
    }
    
    func populateCell(delegate:OnboardingEndCellDelegate, isEntour:Bool, isBeentour:Bool, addressName:String?, isAsso:Bool) {
        self.delegate = delegate
        
        ui_desc_place.text = addressName != nil ? addressName! : "onboard_place_infos_placeholder".localized
        
        self.isEntourCheck = isEntour
        self.isBeEntourCheck = isBeentour
        changeViewCheck()
    }
    
    @IBAction func action_entour(_ sender: Any) {
        isEntourCheck = !isEntourCheck
        changeViewCheck()
        delegate?.updateEntour(isEntour: isEntourCheck, isBeEntour: isBeEntourCheck, isAsso: isAssoCheck)
    }
    @IBAction func action_beentour(_ sender: Any) {
        isBeEntourCheck = !isBeEntourCheck
        changeViewCheck()
        delegate?.updateEntour(isEntour: isEntourCheck, isBeEntour: isBeEntourCheck, isAsso: isAssoCheck)
    }
    @IBAction func action_place(_ sender: Any) {
        delegate?.showSelectLocation()
    }
    @IBAction func action_asso(_ sender: Any) {
        isAssoCheck = !isAssoCheck
        changeViewCheck()
        delegate?.updateEntour(isEntour: isEntourCheck, isBeEntour: isBeEntourCheck, isAsso: isAssoCheck)
    }
}

//MARK: - Protocol OnboardingEndCellDelegate -
protocol OnboardingEndCellDelegate:AnyObject {
    func showSelectLocation()
    func updateEntour(isEntour:Bool, isBeEntour:Bool, isAsso:Bool)
}
