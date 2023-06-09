//
//  WelcomThreeViewController.swift
//  entourage
//
//  Created by Clement entourage on 09/06/2023.
//

import Foundation
import UIKit

protocol WelcomeThreeDelegate {
    
}

class WelcomeThreeViewController:UIViewController{
    
    //OUTLET
    @IBOutlet weak var btn_main: UIButton!
    @IBOutlet weak var ui_top_image: UIImageView!
    @IBOutlet weak var btn_close: UIImageView!
    @IBOutlet weak var top_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_table_view: UITableView!
    
    var delegate:WelcomeThreeDelegate?
    
    override func viewDidLoad() {
        initButton()
    }
    
    func initButton(){
        btn_close.isUserInteractionEnabled = true
         let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
        btn_close.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func closeTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
