//
//  CategoriesBubblesCell.swift
//  entourage
//
//  Created by Jerome on 09/03/2022.
//

import UIKit

class CategoriesBubblesCell: UITableViewCell {
    @IBOutlet weak var ui_constraint_top_margin: NSLayoutConstraint?
    @IBOutlet weak var ui_taglist_view: TagListView!
    
    @IBOutlet weak var ui_title: UILabel?
    let cornerRadiusTag:CGFloat = 15
    let topMarginConstraint:CGFloat = 24
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_title?.textColor = ApplicationTheme.getFontH2Noir().color
        ui_title?.font = ApplicationTheme.getFontH2Noir().font
        ui_title?.text = "detail_user_his_interests".localized
        ui_taglist_view.backgroundColor = .white
        ui_taglist_view.tagBackgroundColor = ApplicationTheme.getFontCategoryBubble().color
        ui_taglist_view.cornerRadius = cornerRadiusTag
        ui_taglist_view.textFont = ApplicationTheme.getFontCategoryBubble().font
        ui_taglist_view.textColor = .appOrange
        ui_taglist_view.alignment = .center
        
        //Values to align and padding tags
        ui_taglist_view.marginY = 12
        ui_taglist_view.marginX = 12
        
        ui_taglist_view.paddingX = 15
        ui_taglist_view.paddingY = 9
    }
    
    func populateCell(interests:[String]?, tagAlignment:TagListView.Alignment = .center) {
        
        ui_taglist_view.alignment = tagAlignment
        
        guard let interests = interests else {
            ui_constraint_top_margin?.constant = 0
            return
        }
        
        ui_taglist_view.removeAllTags()
        for interest in interests {
            if let tagName = Metadatas.sharedInstance.tagsInterest?.getTagNameFrom(key: interest) {
                ui_taglist_view.addTag(tagName)
            }
            else {
                ui_taglist_view.addTag(interest)
            }
        }
        
        if interests.isEmpty {
            ui_constraint_top_margin?.constant = 0
        }
        else {
            ui_constraint_top_margin?.constant = topMarginConstraint
        }
    }
}
