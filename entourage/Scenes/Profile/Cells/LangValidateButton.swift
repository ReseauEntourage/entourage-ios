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
    func onCancel()
}

class LangValidateButton:UITableViewCell{
    class var identifier: String {
        return String(describing: self)
    }
    
    @IBOutlet weak var ui_button: UIButton!
    @IBOutlet weak var ui_btn_cancel: UIButton!
    
    var delegate:OnValidateButtonClickedDelegate?
    
    override func awakeFromNib() {

    }
    func configure(){
        ui_button.addTarget(self, action: #selector(onButtonClicked), for: .touchUpInside)
        ui_btn_cancel.addTarget(self, action: #selector(onCancelClicked), for: .touchUpInside)
        configureOrangeButton(ui_button, withTitle: "validate".localized)
        configureWhiteButton(ui_btn_cancel, withTitle: "cancel".localized)
    }
    
    @objc func onButtonClicked(){
        self.delegate?.onClickedValidate()
    }
    
    @objc func onCancelClicked(){
        self.delegate?.onCancel()
    }
    
    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
      }
      func configureWhiteButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.appOrange.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
      }

}
