//
//  NeighborhoodCreateAddOtherCell.swift
//  entourage
//
//  Created by Jerome on 08/04/2022.
//

import UIKit

class NeighborhoodCreateAddOtherCell: UITableViewCell {
    @IBOutlet weak var ui_description: UILabel!
    
    @IBOutlet weak var ui_tf_description: UITextField!
    
    weak var delegate:NeighborhoodCreateAddOtherDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_description.font = ApplicationTheme.getFontLegend().font
        ui_description.textColor = ApplicationTheme.getFontLegend().color
        ui_description.text = "neighborhoodCreateCatOtherTitle".localized
        
        ui_tf_description.delegate = self
        
        ui_tf_description.placeholder = "neighborhoodCreateCatOtherPlaceholder".localized
        ui_tf_description.font = ApplicationTheme.getFontLegend(size: 13).font
        ui_tf_description.textColor = ApplicationTheme.getFontLegend(size: 13).color
    }
    
    func populateCell(currentWord:String?, delegate:NeighborhoodCreateAddOtherDelegate) {
        ui_tf_description.text = currentWord
        self.delegate = delegate
    }
}

//MARK: - UITextFieldDelegate -
extension NeighborhoodCreateAddOtherCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate?.addMessage(textField.text)
        return true
    }
}

//MARK: - Protocol NeighborhoodCreateAddOtherDelegate -
protocol NeighborhoodCreateAddOtherDelegate: AnyObject {
    func addMessage(_ message:String?)
}
