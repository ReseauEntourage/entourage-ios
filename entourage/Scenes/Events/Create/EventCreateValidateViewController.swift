//
//  EventCreateValidateViewController.swift
//  entourage
//
//  Created by Jerome on 29/06/2022.
//

import UIKit

class EventCreateValidateViewController: UIViewController {
    
    @IBOutlet weak var ui_bt_post: UIButton!
    
    @IBOutlet weak var ui_subtitle: UILabel!
    @IBOutlet weak var ui_title: UILabel!
    
    var eventId:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_bt_post.layer.cornerRadius = ui_bt_post.frame.height / 2
        ui_bt_post.backgroundColor = .appOrange
        ui_bt_post.setTitle("eventCreateEnd_button_show".localized, for: .normal)
        
        ui_bt_post.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 18)
        
        ui_title.text = "eventCreateEnd_title".localized
        ui_subtitle.text = "eventCreateEnd_subtitle".localized
        ui_title.setFontTitle(size: 28)
        ui_subtitle.setFontBody(size: 15)
        configureOrangeButton(ui_bt_post, withTitle: "eventCreateEnd_button_show".localized)
    }
    
    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }
    
    @IBAction func action_show_event(_ sender: Any) {
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationCreateShowNewEvent), object: nil, userInfo: [kNotificationEventShowId:self.eventId])
        }
    }
    
}
