//
//  AddDescriptionTableViewCell.swift
//  entourage
//
//  Created by Jerome on 23/06/2022.
//

import UIKit

class AddDescriptionTableViewCell: UITableViewCell {

    class var identifier: String {
        return String(describing: self)
    }
    
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_description: UILabel!
    
    @IBOutlet weak var ui_view_error: MJErrorInputTextView?
    @IBOutlet weak var ui_tv_count: UILabel!
    @IBOutlet weak var ui_tv_edit: MJTextViewPlaceholder!
    
    @IBOutlet weak var ui_tv_growing: GrowingTextView!
    
    weak var delegate:AddDescriptionCellDelegate? = nil
    
    var placeholderTxt = ""
    
    var textInputType:TextInputType = .none
    
    var originalGrowingTf:CGFloat = 0
    var lastGrowingTf:CGFloat = 0
    
    var maxCharsLimit = ApplicationTheme.maxCharsDescription
    var showError:Bool = true
    
    weak var tableView: UITableView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let _width = UIApplication.shared.delegate?.window??.frame.width ?? contentView.frame.size.width
        let buttonDone = UIBarButtonItem(title: "validate".localized, style: .plain, target: self, action: #selector(closeKb(_:)))
        
        if let _ = ui_tv_growing {
            ui_tv_growing.delegate = self
            ui_tv_growing.trimWhiteSpaceWhenEndEditing = false
            ui_tv_growing.font = ApplicationTheme.getFontChampDefault().font
            ui_tv_growing.placeholder = placeholderTxt
            ui_tv_growing.placeholderColor = ApplicationTheme.getFontChampDefault().color
            ui_tv_growing.addToolBar(width: _width, buttonValidate: buttonDone)
            
            ui_tv_growing.maxHeight = 140
            
        }
        
        if let _ = ui_tv_edit {
            ui_tv_edit.delegate = self
            ui_tv_edit.isScrollEnabled = true
            ui_tv_edit.placeholderText = placeholderTxt
            ui_tv_edit.placeholderColor = ApplicationTheme.getFontChampDefault().color
            ui_tv_edit.addToolBar(width: _width, buttonValidate: buttonDone)
            ui_tv_edit.font = ApplicationTheme.getFontChampDefault().font
        }
        
        ui_tv_count.text = "0/\(maxCharsLimit)"
        
        ui_title.text = "neighborhoodCreateDescriptionTitle".localized
        ui_title.textColor = ApplicationTheme.getFontH2Noir().color
        ui_title.font = ApplicationTheme.getFontH2Noir(size: 15).font
        
        ui_description.text = "neighborhoodCreateDescriptionSubtitle".localized
        ui_description.textColor = ApplicationTheme.getFontLegend().color
        ui_description.font = ApplicationTheme.getFontLegend(size: 13).font
        
        ui_view_error?.isHidden = true
        self.ui_view_error?.setupView(title: "neighborhoodCreateInputErrorMandatory".localized)
    }
    
    func populateCell(title:String,titleAttributted:NSAttributedString? = nil, description:String, placeholder:String, delegate:AddDescriptionCellDelegate, about:String? = nil, textInputType:TextInputType, charMaxLimit:Int = ApplicationTheme.maxCharsDescription, showError:Bool = true, tableview:UITableView? = nil) {
        self.maxCharsLimit = charMaxLimit
        self.textInputType = textInputType
        let _about = about?.count ?? 0 > 0 ? about! : ""
        self.ui_tv_edit?.text = _about
        self.ui_tv_growing?.text = _about
        self.delegate = delegate
        
        self.showError = showError
        
        ui_tv_count.text = "\(_about.count)/\(maxCharsLimit)"
        
        if let titleAttributted = titleAttributted {
            ui_title.attributedText = titleAttributted
        }
        else {
            ui_title.text = title
        }
        ui_description.text = description
        placeholderTxt = placeholder
        ui_tv_edit?.placeholderText = placeholderTxt
        ui_tv_growing?.placeholder = placeholderTxt
        self.tableView = tableview
    }
    
    @objc func closeKb(_ sender:UIBarButtonItem?) {
        if let txtBio = ui_tv_edit?.text {
            let _bio = txtBio == placeholderTxt ? "" : txtBio
            delegate?.updateFromTextView(text: _bio,textInputType: textInputType)
        }
        else if let txtBio = ui_tv_growing?.text {
            let _bio = txtBio == placeholderTxt ? "" : txtBio
            delegate?.updateFromTextView(text: _bio,textInputType: textInputType)
        }
        
        if showError {
            if ui_tv_growing != nil {
                ui_view_error?.isHidden = ui_tv_growing.text?.isEmpty ?? true ? false : true
                _ = ui_tv_growing.resignFirstResponder()
            }
            else {
                ui_view_error?.isHidden = ui_tv_edit.text?.isEmpty ?? true ? false : true
                _ = ui_tv_edit.resignFirstResponder()
            }
        }
        else {
            if ui_tv_growing != nil {
                _ = ui_tv_growing.resignFirstResponder()
            }
            else {
                _ = ui_tv_edit.resignFirstResponder()
            }
            ui_view_error?.isHidden = true
        }
    }
}

//MARK: - Growing delegate
extension AddDescriptionTableViewCell: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        
        if originalGrowingTf == 0 {
            originalGrowingTf = height
            return
        }
        
        //To force refresh cell
        UIView.setAnimationsEnabled(false)
        tableView?.beginUpdates()
        tableView?.endUpdates()
        UIView.setAnimationsEnabled(true)
        
        if height >= originalGrowingTf {
            let oldHeight = lastGrowingTf
            lastGrowingTf = height
            let isUp = lastGrowingTf > oldHeight
            let notif = Notification(name: Notification.Name(kNotifGrowTextview), object: nil, userInfo: [kNotifGrowTextviewKeyISUP:isUp])
            NotificationCenter.default.post(notif)
        }
    }
}

//MARK: - UITextViewDelegate -
extension AddDescriptionTableViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //TODO: ON garde quel comportement? avec ou sans retour à la ligne ?
//        if text == "\n" {
//            self.closeKb(nil)
//            return false
//        }
        
        if textView.text.count + text.count > maxCharsLimit {
            return false
        }
        
        ui_tv_count.text = "\(textView.text.count + text.count)/\(maxCharsLimit)"
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        lastGrowingTf = 0
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.updateFromTextView(text: textView.text,textInputType: textInputType)
    }
}

//MARK: - AddDescriptionCellDelegate Protocol -
protocol AddDescriptionCellDelegate:AnyObject {
    func updateFromTextView(text:String?, textInputType:TextInputType)
}

enum TextInputType {
    case descriptionAbout
    case descriptionWelcome
    case none
}


class AddDescriptionFixedTableViewCell:AddDescriptionTableViewCell {}
