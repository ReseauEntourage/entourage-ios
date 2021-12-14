//
//  OTEditActionPublicPrivateViewController.swift
//  entourage
//
//  Created by Jerome on 17/09/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

@objc class OTEditActionPublicPrivateViewController: UIViewController {
    
    @objc var entourage:OTEntourage? = nil
    
    @IBOutlet weak var ui_label_public_title: UILabel!
    @IBOutlet weak var ui_label_public_description: UILabel!
    @IBOutlet weak var ui_iv_public_circle_big: UIImageView!
    @IBOutlet weak var ui_iv_public_circle_small: UIImageView!
    
    @IBOutlet weak var ui_label_private_title: UILabel!
    @IBOutlet weak var ui_label_private_description: UILabel!
    @IBOutlet weak var ui_iv_private_circle_big: UIImageView!
    @IBOutlet weak var ui_iv_private_circle_small: UIImageView!
    
    @objc weak var delegate:EditPrivacyDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_iv_public_circle_big.layer.cornerRadius = ui_iv_public_circle_big.frame.width / 2
        ui_iv_public_circle_big.layer.borderWidth = 2
        
        ui_iv_public_circle_small.layer.cornerRadius = ui_iv_public_circle_small.frame.width / 2
        
        ui_iv_private_circle_big.layer.cornerRadius = ui_iv_private_circle_big.frame.width / 2
        ui_iv_private_circle_big.layer.borderWidth = 2
        
        
        ui_iv_private_circle_small.layer.cornerRadius = ui_iv_private_circle_small.frame.width / 2
        
        
        changeButtonsImage()
    }
    
    func changeButtonsImage() {
        if entourage?.isPublic.boolValue ?? true {
            ui_iv_public_circle_big.layer.borderColor = UIColor.appOrange().cgColor
            ui_iv_public_circle_small.backgroundColor = UIColor.appOrange()
            
            ui_iv_private_circle_big.layer.borderColor = UIColor.appGreyish().cgColor
            ui_iv_private_circle_small.backgroundColor = UIColor.white
        }
        else {
            ui_iv_public_circle_big.layer.borderColor = UIColor.appGreyish().cgColor
            ui_iv_public_circle_small.backgroundColor = UIColor.white
            
            ui_iv_private_circle_big.layer.borderColor = UIColor.appOrange().cgColor
            ui_iv_private_circle_small.backgroundColor = UIColor.appOrange()
        }
    }
    
    @IBAction func action_select_public(_ sender: Any) {
        entourage?.isPublic = true
        changeButtonsImage()
        delegate?.privacyEdited(isPublic: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func action_select_private(_ sender: Any) {
        entourage?.isPublic = false
        changeButtonsImage()
        delegate?.privacyEdited(isPublic: false)
        self.navigationController?.popViewController(animated: true)
    }
}


@objc protocol EditPrivacyDelegate  {
    @objc func privacyEdited(isPublic:Bool)
}
