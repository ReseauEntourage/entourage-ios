//
//  ActionPassedTwoVC.swift
//  entourage
//
//  Created by Clement entourage on 19/07/2023.
//

import Foundation

class ActionPassedTwoVC:UIViewController {
    
    //OUTLET
    @IBOutlet weak var ui_label: UILabel!
    @IBOutlet weak var ui_btn: UIButton!
    @IBOutlet weak var ic_cross: UILabel!
    
    //VARIABLE
    
    override func viewDidLoad() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onCrossClicked(tapGestureRecognizer:)))
        ic_cross.addGestureRecognizer(tapGestureRecognizer)

        
    }
    
    @objc func onCrossClicked(tapGestureRecognizer: UITapGestureRecognizer){
        self.dismiss(animated: true) {
            
        }
    }
    
}
