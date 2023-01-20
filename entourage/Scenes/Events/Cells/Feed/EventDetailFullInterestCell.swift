//
//  EventDetailFullInterestCell.swift
//  entourage
//
//  Created by Jerome on 12/07/2022.
//

import UIKit

class EventDetailFullInterestCell: UITableViewCell {

    class var identifier:String {return String(describing: self) }

    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_taglist_view: TagListView!
    let cornerRadiusTag:CGFloat = 15
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title?.setupFontAndColor(style: ApplicationTheme.getFontH2Noir())
        ui_title?.text = "event_detail_cat_title".localized
        
        ui_taglist_view?.backgroundColor = .appBeigeClair
        ui_taglist_view?.tagBackgroundColor = ApplicationTheme.getFontCategoryBubble().color
        ui_taglist_view?.cornerRadius = cornerRadiusTag
        ui_taglist_view?.textFont = ApplicationTheme.getFontCategoryBubble().font
        ui_taglist_view?.textColor = .appOrange
        ui_taglist_view?.alignment = .left
        
        //Values to align and padding tags
        ui_taglist_view?.marginY = 12
        ui_taglist_view?.marginX = 12
        
        ui_taglist_view?.paddingX = 15
        ui_taglist_view?.paddingY = 9
    }

    func populateCell(interests:[String]?) {
        ui_taglist_view?.removeAllTags()
        guard let interests = interests else {return}
        
        if interests.count > 1 {
            ui_title?.text = "event_detail_cats_title".localized
        }
        else {
            ui_title?.text = "event_detail_cat_title".localized
        }
        
        for interest in interests {
            if let tagName = Metadatas.sharedInstance.tagsInterest?.getTagNameFrom(key: interest) {
                ui_taglist_view?.addTag(tagName)
            }
            else {
                ui_taglist_view?.addTag(interest)
            }
        }
    }
    
}
