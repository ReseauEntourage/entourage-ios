//
//  EnhancedOnboardingTitle.swift
//  entourage
//
//  Created by Clement entourage on 23/05/2024.
//

import Foundation
import UIKit


class EnhancedOnboardingTitle:UITableViewCell{
    
    //Outlet
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_subtitle_label: UILabel!
    
    //Variable
    
    override func awakeFromNib() {
        
    }
    
    func configure(title:String , subtitle:String){
        self.ui_title.text = title
        self.ui_subtitle_label.text = subtitle
    }
    
}
