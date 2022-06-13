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
    @IBOutlet weak var ui_bt_search: UIButton!
    
    weak var delegate:NeighborhoodHomeSearchDelegate? = nil
    var isCellUserSearch = false
    var hasAlreadySendAnalytic = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_view_search.layer.cornerRadius = 20//ui_view_search.frame.height / 2
        ui_view_search.layer.borderColor = UIColor.appOrange.cgColor
        ui_view_search.layer.borderWidth = 1
        
        ui_search_textfield.setupFontAndColor(style: ApplicationTheme.getFontChampInput())
        ui_search_textfield.placeholder = "neighborhoodInputSearch".localized
        ui_search_textfield.delegate = self
        
    }
    
    func populateCell(delegate:NeighborhoodHomeSearchDelegate, isSearch:Bool, placeceholder:String? = nil, isCellUserSearch:Bool) {
        self.delegate = delegate
        self.isCellUserSearch = isCellUserSearch
        
        if !isSearch {
            ui_search_textfield.text = ""
            ui_bt_search.isHidden = true
        }
        else {
            ui_bt_search.isHidden = false
        }
        
        if ui_search_textfield.text?.count ?? 0 > 0 {
            ui_bt_search.isHidden = false
        }
        else {
            ui_bt_search.isHidden = true
        }
        
        if let placeceholder = placeceholder {
            ui_search_textfield.placeholder = placeceholder
           // ui_bt_search.isHidden = false
        }
    }
    
    @IBAction func action_clear(_ sender: Any) {
        if ui_search_textfield.text?.isEmpty ?? true { return }
        
        ui_search_textfield.text = ""
        delegate?.goSearch("")
        ui_bt_search.isHidden = true
        
        if isCellUserSearch {
            AnalyticsLoggerManager.logEvent(name: Action_GroupMember_Search_Delete)
        }
        else {
            AnalyticsLoggerManager.logEvent(name: Action_Group_Search_Delete)
        }
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
        if !hasAlreadySendAnalytic {
            hasAlreadySendAnalytic = true
            if isCellUserSearch {
                AnalyticsLoggerManager.logEvent(name: Action_GroupMember_Search_Start)
            }
            else {
                AnalyticsLoggerManager.logEvent(name: Action_Group_Search_Start)
            }
        }
        else {
            hasAlreadySendAnalytic = false
        }
        
        if textField.text?.count == 0 {
            delegate?.showEmptySearch()
            ui_bt_search.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.ui_search_textfield.becomeFirstResponder()
            }
        }
        else {
            ui_bt_search.isHidden = false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var count = textField.text?.count ?? 0
        count = count + (string.isEmpty ? -1 : 1)
        if count > 0 {
            ui_bt_search.isHidden = false
        }
        else {
            ui_bt_search.isHidden = true
        }
        return true
    }
}

//MARK: - Protocol NeighborhoodCreateAddOtherDelegate -
protocol NeighborhoodHomeSearchDelegate: AnyObject {
    func goSearch(_ text:String?)
    func showEmptySearch()
}
