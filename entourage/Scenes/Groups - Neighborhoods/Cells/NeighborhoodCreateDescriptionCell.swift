//
//  NeighborhoodInputTextviewTableViewCell.swift
//  entourage
//
//  Created by Jerome on 07/04/2022.
//

import UIKit

class NeighborhoodCreateDescriptionCell: UITableViewCell {
    
    @IBOutlet weak var ui_title_bio: UILabel!
    @IBOutlet weak var ui_description: UILabel!
    
    @IBOutlet weak var ui_view_error: MJErrorInputTextView?
    @IBOutlet weak var ui_bio_count: UILabel!
    @IBOutlet weak var ui_tv_edit_bio: MJTextViewPlaceholder!
    
    @IBOutlet weak var ui_tv_growing: GrowingTextView!
    
    weak var delegate:NeighborhoodCreateDescriptionCellDelegate? = nil
    
    var placeholderTxt = "neighborhoodCreateTitleDescriptionPlaceholder".localized
    
    var textInputType:TextInputType = .none
    
    var originalGrowingTf:CGFloat = 0
    var lastGrowingTf:CGFloat = 0
    
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
            
            ui_tv_growing.maxHeight = 80
        }
        
        if let _ = ui_tv_edit_bio {
            ui_tv_edit_bio.delegate = self
            ui_tv_edit_bio.isScrollEnabled = false
            ui_tv_edit_bio.placeholderText = placeholderTxt
            ui_tv_edit_bio.placeholderColor = ApplicationTheme.getFontChampDefault().color
            ui_tv_edit_bio.addToolBar(width: _width, buttonValidate: buttonDone)
            ui_tv_edit_bio.font = ApplicationTheme.getFontChampDefault().font
        }
        
        ui_bio_count.text = "0/\(ApplicationTheme.maxCharsDescription)"
        
        ui_title_bio.text = "neighborhoodCreateDescriptionTitle".localized
        ui_title_bio.textColor = ApplicationTheme.getFontH2Noir().color
        ui_title_bio.font = ApplicationTheme.getFontH2Noir(size: 15).font
        
        ui_description.text = "neighborhoodCreateDescriptionSubtitle".localized
        ui_description.textColor = ApplicationTheme.getFontLegend().color
        ui_description.font = ApplicationTheme.getFontLegend(size: 13).font
        
        ui_view_error?.isHidden = true
        self.ui_view_error?.setupView(title: "neighborhoodCreateInputErrorMandatory".localized)
    }
    
    private func setupTitles(title:String,description:String,placeholder:String) {
        ui_title_bio.text = title.localized
        ui_description.text = description.localized
        placeholderTxt = placeholder.localized
        ui_tv_edit_bio?.placeholderText = placeholderTxt
        ui_tv_growing?.placeholder = placeholderTxt
    }
    
    func populateCell(title:String,description:String,placeholder:String, delegate:NeighborhoodCreateDescriptionCellDelegate, about:String? = nil, textInputType:TextInputType) {
        self.textInputType = textInputType
        self.ui_tv_edit_bio?.text = about
        self.ui_tv_growing?.text = about
        self.delegate = delegate
        setupTitles(title: title, description: description, placeholder: placeholder)
    }
    
    @objc func closeKb(_ sender:UIBarButtonItem?) {
        if let txtBio = ui_tv_edit_bio?.text {
            let _bio = txtBio == placeholderTxt ? "" : txtBio
            delegate?.updateFromTextView(text: _bio,textInputType: textInputType)
        }
        else if let txtBio = ui_tv_growing?.text {
            let _bio = txtBio == placeholderTxt ? "" : txtBio
            delegate?.updateFromTextView(text: _bio,textInputType: textInputType)
        }
        
        if ui_tv_growing != nil {
            ui_view_error?.isHidden = ui_tv_growing.text?.isEmpty ?? true ? false : true
            _ = ui_tv_growing.resignFirstResponder()
        }
        else {
            ui_view_error?.isHidden = ui_tv_edit_bio.text?.isEmpty ?? true ? false : true
            _ = ui_tv_edit_bio.resignFirstResponder()
        }
    }
}

//MARK: - Growing delegate
extension NeighborhoodCreateDescriptionCell: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        if originalGrowingTf == 0 {
            originalGrowingTf = height
            return
        }
        
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
extension NeighborhoodCreateDescriptionCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //TODO: ON garde quel comportement? avec ou sans retour à la ligne ?
//        if text == "\n" {
//            self.closeKb(nil)
//            return false
//        }
        
        if textView.text.count + text.count > ApplicationTheme.maxCharsDescription {
            return false
        }
        
        ui_bio_count.text = "\(textView.text.count + text.count)/\(ApplicationTheme.maxCharsDescription)"
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        lastGrowingTf = 0
    }
}

//MARK: - NeighborhoodCreateDescriptionCellDelegate Protocol -
protocol NeighborhoodCreateDescriptionCellDelegate:AnyObject {
    func updateFromTextView(text:String?, textInputType:TextInputType)
}

enum TextInputType {
    case descriptionAbout
    case descriptionWelcome
    case none
}
