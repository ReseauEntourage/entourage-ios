//
//  NeighborhoodCreateValidateViewController.swift
//  entourage
//
//  Created by Jerome on 13/04/2022.
//

import UIKit

class NeighborhoodCreateValidateViewController: UIViewController {
    
    @IBOutlet weak var ui_bt_post: UIButton!
    @IBOutlet weak var ui_bt_pass: UIButton!
    
    @IBOutlet weak var ui_subtitle: UILabel!
    @IBOutlet weak var ui_title: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_bt_pass.layer.cornerRadius = ui_bt_pass.frame.height / 2
        ui_bt_pass.layer.borderColor = UIColor.appOrange.cgColor
        ui_bt_pass.layer.borderWidth = 1
        
        ui_bt_pass.setTitle("neighborhoodCreateValidatePass".localized, for: .normal)
        
        ui_bt_post.layer.cornerRadius = ui_bt_pass.frame.height / 2
        ui_bt_post.backgroundColor = .appOrange
        ui_bt_post.setTitle("neighborhoodCreateValidatePostMessage".localized, for: .normal)
        
        ui_bt_post.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 18)
        
        ui_title.text = "neighborhoodCreateValidateTitle".localized
        ui_subtitle.text = "neighborhoodCreateValidateSubtitle".localized
    }
    
    @IBAction func action_post_message(_ sender: Any) {
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "fermer".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        
        customAlert.configureAlert(alertTitle: "W I P".localized, message: "Pas encore implémenté.\nCliquer sur passer pour fermer ;)".localized, buttonrightType: buttonAccept, buttonLeftType: nil, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, parentVC: self)
        
        customAlert.alertTagName = .None
        customAlert.show()
    }
    
    @IBAction func action_pass(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
