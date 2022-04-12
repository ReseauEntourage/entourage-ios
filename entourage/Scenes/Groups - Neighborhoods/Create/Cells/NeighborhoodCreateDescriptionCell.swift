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
    
    @IBOutlet weak var ui_bio_count: UILabel!
    @IBOutlet weak var ui_tv_edit_bio: MJTextViewPlaceholder!
    
    weak var delegate:NeighborhoodCreateDescriptionCellDelegate? = nil
    
    let placeholderTxt = "neighborhoodCreateTitleDescriptionPlaceholder".localized
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_tv_edit_bio.delegate = self
        ui_tv_edit_bio.isScrollEnabled = false
        ui_bio_count.text = "0/\(ApplicationTheme.maxCharsBio)"
        
        ui_tv_edit_bio.placeholderText = placeholderTxt
        ui_tv_edit_bio.placeholderColor = ApplicationTheme.getFontChampDefault().color
        
        let _width = UIApplication.shared.delegate?.window??.frame.width ?? contentView.frame.size.width
        let buttonDone = UIBarButtonItem(title: "validate".localized, style: .plain, target: self, action: #selector(closeKb(_:)))
        ui_tv_edit_bio.addToolBar(width: _width, buttonValidate: buttonDone)
        ui_tv_edit_bio.font = ApplicationTheme.getFontChampDefault().font
        
        ui_title_bio.text = "neighborhoodCreateDescriptionTitle".localized
        ui_title_bio.textColor = ApplicationTheme.getFontH2Noir().color
        ui_title_bio.font = ApplicationTheme.getFontH2Noir(size: 15).font
        
        ui_description.text = "neighborhoodCreateDescriptionSubtitle".localized
        ui_description.textColor = ApplicationTheme.getFontLegend().color
        ui_description.font = ApplicationTheme.getFontLegend(size: 13).font
    }
    
    func populateCell(delegate:NeighborhoodCreateDescriptionCellDelegate) {
        self.delegate = delegate
    }
    
    @objc func closeKb(_ sender:UIBarButtonItem!) {
        if let txtBio = ui_tv_edit_bio.text {
            let _bio = txtBio == placeholderTxt ? "" : txtBio
            delegate?.updateFromTextView(text: _bio)
        }
        _ = ui_tv_edit_bio.resignFirstResponder()
    }
}

//MARK: - UITextViewDelegate -
extension NeighborhoodCreateDescriptionCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //TODO: ON garde quel comportement? avec ou sans retour à la ligne ?
        if text == "\n" {
            delegate?.updateFromTextView(text: textView.text)
            textView.resignFirstResponder()
            return false
        }
        
        if textView.text.count + text.count > ApplicationTheme.maxCharsBio {
            return false
        }
        
        ui_bio_count.text = "\(textView.text.count + text.count)/\(ApplicationTheme.maxCharsBio)"
        
        return true
    }
}

//MARK: - NeighborhoodCreateDescriptionCellDelegate Protocol -
protocol NeighborhoodCreateDescriptionCellDelegate:AnyObject {
    func updateFromTextView(text:String?)
}