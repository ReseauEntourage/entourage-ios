//
//  ActionCreateValidateViewController.swift
//  entourage
//
//  Created by Jerome on 02/08/2022.
//

import UIKit

class ActionCreateValidateViewController: UIViewController {
    
    @IBOutlet weak var ui_bt_post: UIButton!
    
    @IBOutlet weak var ui_subtitle: UILabel!
    @IBOutlet weak var ui_title: UILabel!
    
    @IBOutlet weak var ui_iv_line_top_right: UIImageView!
    @IBOutlet weak var ui_iv_line_top_left: UIImageView!
    @IBOutlet weak var ui_iv_line_bottom_right: UIImageView!
    var actionId:Int = -1
    
    var isContrib = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_bt_post.layer.cornerRadius = ui_bt_post.frame.height / 2
        ui_bt_post.backgroundColor = .appOrange
        ui_bt_post.setTitle("action_create_close_button".localized, for: .normal)
        
        ui_bt_post.titleLabel?.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
        
        if isContrib {
            ui_iv_line_top_right.isHidden = true
            ui_title.text = "contribCreateEnd_title".localized
            ui_subtitle.text = "contribCreateEnd_subtitle".localized
        }
        else {
            ui_iv_line_top_left.isHidden = true
            ui_iv_line_bottom_right.isHidden = true
            ui_title.text = "solicitationCreateEnd_title".localized
            ui_subtitle.text = "solicitationCreateEnd_subtitle".localized
        }
    }
    
    @IBAction func action_show_action(_ sender: Any) {
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationCreateShowNewAction), object: nil, userInfo: [kNotificationActionShowId:self.actionId])
        }
    }
}
