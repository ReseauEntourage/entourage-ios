//
//  ActionPassedOneVC.swift
//  entourage
//
//  Created by Clement entourage on 19/07/2023.
//

import Foundation

protocol ActionPassedOneVCDelegate{
    func onDemandClick()
}

class ActionPassedOneVC:UIViewController {
    
    //OUTLET
    @IBOutlet weak var ui_label: UILabel!
    @IBOutlet weak var ic_cross: UIImageView!
    
    //VARIABLE
    
    override func viewDidLoad() {
        ic_cross.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onCrossClicked(tapGestureRecognizer:)))
        ic_cross.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc func onCrossClicked(tapGestureRecognizer: UITapGestureRecognizer){
        self.dismiss(animated: true) {
            
        }
    }
    
}
