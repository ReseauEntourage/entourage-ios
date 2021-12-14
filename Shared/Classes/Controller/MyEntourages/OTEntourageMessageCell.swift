//
//  OTEntourageMessageCell.swift
//  entourage
//
//  Created by Jerome on 13/12/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTEntourageMessageCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblTimeDistance:UILabel!
    @IBOutlet weak var lblLastMessage:UILabel!
    @IBOutlet weak var imgCategory:UIImageView!

    var summaryProvider:OTSummaryProviderBehavior? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        summaryProvider = OTSummaryProviderBehavior()
    }
    
    func configureWith(feedItem:OTFeedItem) {
        let readFontLarge = UIFont(name: "SFUIText-Regular", size: 16)
        let unReadFontLarge = UIFont(name: "SFUIText-Bold", size: 16)
        let readFontSmall = UIFont(name: "SFUIText-Regular", size: 14)
        let unReadFontSmall = UIFont(name: "SFUIText-Bold", size: 14)
        
        let readColor = UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1)
        
        let lightFont = UIFont(name:"SFUIText-Light", size:14)
        
        self.summaryProvider?.lblTitle = self.lblTitle
        self.summaryProvider?.lblTimeDistance = self.lblTimeDistance
        self.summaryProvider?.imgCategory = self.imgCategory
        self.summaryProvider?.showRoundedBorder = true
        self.summaryProvider?.showTimeAsUpdatedDate = true
        self.summaryProvider?.imgCategorySize = CGSize(width: 25, height: 35)
        
        setupSubtitle(item: feedItem)
        self.summaryProvider?.isFromMyEntourages = true
        self.summaryProvider?.configure(with: feedItem)
        self.summaryProvider?.clearConfiguration()
        
        if feedItem.unreadMessageCount.intValue > 0 {
            self.lblTitle.font = unReadFontLarge
            self.lblTitle.textColor = UIColor.black

            self.lblLastMessage.font = unReadFontSmall
            self.lblLastMessage.textColor = UIColor.black

            self.lblTimeDistance.font = unReadFontSmall
            self.lblTimeDistance.textColor = UIColor.black
        }
        else {
            self.lblTitle.font = readFontLarge
            self.lblTitle.textColor = readColor

            self.lblLastMessage.font = readFontSmall
            self.lblLastMessage.textColor = UIColor.appGreyish()

            self.lblTimeDistance.font = lightFont
            self.lblTimeDistance.textColor = readColor
        }
        setupSubtitle(item: feedItem)
    }
    
    func setupSubtitle(item:OTFeedItem) {
        let lastMessage = getAuthorText(lastMEssage: item.lastMessage)
        
        if lastMessage.count > 0 {
            summaryProvider?.lblDescription = self.lblLastMessage
            self.lblLastMessage.text = lastMessage
        }
        else {
            summaryProvider?.lblDescription = self.lblLastMessage
        }
    }
    
    func getAuthorText(lastMEssage:OTMyFeedMessage?) -> String {
        var messageStr = ""
        let currentUSer = UserDefaults.standard.currentUser
        let isMe = currentUSer?.sid == lastMEssage?.authorId
        
        if isMe {
            messageStr = "Vous"
        }
        else {
            if let lastMsgName = lastMEssage?.displayName, lastMsgName.count > 0 {
                messageStr = lastMsgName
            }
        }
        
        if messageStr.count > 0 {
            messageStr = messageStr + " : "
            if let lastmsg = lastMEssage?.text {
                messageStr = messageStr + lastmsg
            }
        }
        
        return messageStr
    }
}
