//
//  NeighborhoodHomeSearch.swift
//  entourage
//
//  Created by Jerome on 22/04/2022.
//

import UIKit

class NeighborhoodHomeSearchCell: UITableViewCell {
    
    @IBOutlet weak var ui_search_textfield: UITextField!
    @IBOutlet weak var ui_view_search: UIView!
    
    weak var delegate:NeighborhoodHomeSearchDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_view_search.layer.cornerRadius = ui_view_search.frame.height / 2
        ui_view_search.layer.borderColor = UIColor.appOrange.cgColor
        ui_view_search.layer.borderWidth = 1
        
        ui_search_textfield.setupFontAndColor(style: ApplicationTheme.getFontChampInput())
        ui_search_textfield.placeholder = "neighborhoodInputSearch".localized
        ui_search_textfield.delegate = self
        
    }
    
    func populateCell(delegate:NeighborhoodHomeSearchDelegate, isSearch:Bool) {
        self.delegate = delegate
        if !isSearch {
            ui_search_textfield.text = ""
        }
    }
    
    @IBAction func action_clear(_ sender: Any) {
        if ui_search_textfield.text?.isEmpty ?? true { return }
        
        ui_search_textfield.text = ""
        delegate?.goSearch("")
    }
    
    @IBAction func action_search_show(_ sender: Any) {
        ui_search_textfield.becomeFirstResponder()
    }
}

//MARK: - UITextFieldDelegate -
extension NeighborhoodHomeSearchCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate?.goSearch(textField.text)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text?.count == 0 {
            delegate?.showEmptySearch()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.ui_search_textfield.becomeFirstResponder()
            }
        }
    }
}

//MARK: - Protocol NeighborhoodCreateAddOtherDelegate -
protocol NeighborhoodHomeSearchDelegate: AnyObject {
    func goSearch(_ text:String?)
    func showEmptySearch()
}
