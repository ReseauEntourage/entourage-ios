//
//  LangValidateButton.swift
//  entourage
//
//  Created by Clement entourage on 30/10/2023.
//

import Foundation
import UIKit

protocol OnValidateButtonClickedDelegate {
    func onClickedValidate()
}

class LangValidateButton:UITableViewCell{
    class var identifier: String {
        return String(describing: self)
    }
    
    @IBOutlet weak var ui_button: UIButton!
    
    var delegate:OnValidateButtonClickedDelegate?
    
    override func awakeFromNib() {

    }
    func configure(){
        ui_button.setTitle("validate".localized, for: .normal)
        ui_button.addTarget(self, action: #selector(onButtonClicked), for: .touchUpInside)
    }
    
    @objc func onButtonClicked(){
        self.delegate?.onClickedValidate()
    }
}
