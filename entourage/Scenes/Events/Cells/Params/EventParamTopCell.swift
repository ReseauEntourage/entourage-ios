//
//  EventParamTopCell.swift
//  entourage
//
//  Created by Jerome on 25/07/2022.
//

import UIKit

class EventParamTopCell: UITableViewCell {

    @IBOutlet weak var ui_description: UILabel!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_taglist: TagListView!
    @IBOutlet weak var ui_constraint_listview_top_margin: NSLayoutConstraint?
    
    let topMarginConstraint:CGFloat = 12
    let cornerRadiusTag:CGFloat = 15
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
        ui_description.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        ui_taglist.backgroundColor = .appBeigeClair
        ui_taglist.tagBackgroundColor = ApplicationTheme.getFontCategoryBubble().color
        ui_taglist.cornerRadius = cornerRadiusTag
        ui_taglist.textFont = ApplicationTheme.getFontCategoryBubble().font
        ui_taglist.textColor = .appOrange
        ui_taglist.alignment = .center
        
        //Values to align and padding tags
        ui_taglist.marginY = 12
        ui_taglist.marginX = 12
        
        ui_taglist.paddingX = 15
        ui_taglist.paddingY = 9
        ui_taglist.alignment = .left
    }
    
    func populateCell(event:Event?) {
        
        guard let event = event else {
            return
        }
        
        ui_title.text = event.title
        let addressName:String = event.addressName ?? "-"
        let count = event.membersCount ?? 1
        let participants = count == 1 ? "neighborhood_params_participant".localized : "neighborhood_params_participants".localized
        ui_description.text = "\(count) \(participants). \(addressName)"
        
        if let _interests = event.interests {
            ui_taglist.removeAllTags()
            for interest in _interests {
                if let tagName = Metadatas.sharedInstance.tagsInterest?.getTagNameFrom(key: interest) {
                    ui_taglist.addTag(TagsUtils.showTagTranslated(tagName))
                }
                else {
                    ui_taglist.addTag(interest)
                }
            }
            if _interests.isEmpty {
                ui_constraint_listview_top_margin?.constant = 0
            }
            else {
                ui_constraint_listview_top_margin?.constant = topMarginConstraint
            }
        }
        else {
            ui_constraint_listview_top_margin?.constant = topMarginConstraint
        }
        
        ui_taglist.layoutIfNeeded()
        contentView.layoutIfNeeded()
    }
}
