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
    
    var newNeighborhood:Neighborhood? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_bt_pass.layer.cornerRadius = ui_bt_pass.frame.height / 2
        ui_bt_pass.layer.borderColor = UIColor.appOrange.cgColor
        ui_bt_pass.layer.borderWidth = 1
        
        ui_bt_pass.setTitle("neighborhoodCreateValidatePass".localized, for: .normal)
        
        ui_bt_post.layer.cornerRadius = ui_bt_post.frame.height / 2
        ui_bt_post.backgroundColor = .appOrange
        ui_bt_post.setTitle("neighborhoodCreateValidatePostMessage".localized, for: .normal)
        
        ui_bt_post.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 18)
        
        ui_title.text = "neighborhoodCreateValidateTitle".localized
        ui_subtitle.text = "neighborhoodCreateValidateSubtitle".localized
        ui_title.setFontTitle(size: 28)
        ui_subtitle.setFontBody(size: 15)
        
        AnalyticsLoggerManager.logEvent(name: View_NewGroup_Confirmation)
    }
    
    @IBAction func action_post_message(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Action_NewGroup_Confirmation_NewPost)
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationCreatePostNewNeighborhood), object: nil, userInfo: ["neighborhoodId":self.newNeighborhood?.uid as Any])
        }
    }
    
    @IBAction func action_pass(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Action_NewGroup_Confirmation_Skip)
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNeighborhoodShowNew), object: nil, userInfo: ["neighborhoodId":self.newNeighborhood?.uid as Any])
        }
    }
}
