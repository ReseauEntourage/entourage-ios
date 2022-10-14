//
//  InviteSourceViewController.swift
//  entourage
//
//  Created by Jerome on 20/01/2022.
//

import UIKit

class InviteSourceViewController: UIViewController {

    @IBOutlet weak var popupContainerView:UIView!
    
    @IBOutlet weak var ui_bt_share_entourage: UIButton!
    @IBOutlet weak var ui_bt_share_link: UIButton!
    
    weak var delegate:InviteSourceDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ui_bt_share_link.layer.borderColor = UIColor.appOrange.cgColor
        ui_bt_share_link.layer.cornerRadius = 5
        ui_bt_share_link.layer.borderWidth = 1
        
        ui_bt_share_entourage.layer.borderColor = UIColor.appOrange.cgColor
        ui_bt_share_entourage.layer.cornerRadius = 5
        ui_bt_share_entourage.layer.borderWidth = 1
    }
    
    @IBAction func action_close_pop(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func action_share_entourage(_ sender: Any) {
        delegate?.shareEntourage()
        action_close_pop(sender)
    }
    @IBAction func action_share_link(_ sender: Any) {
        delegate?.share()
    }
}


protocol InviteSourceDelegate: AnyObject {
    func share()
    func shareEntourage()
}
