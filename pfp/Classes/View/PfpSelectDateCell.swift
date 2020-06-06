//
//  PfpSelectDateCell.swift
//  pfp
//
//  Created by Smart Care on 05/06/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import UIKit

enum DateSelectionType:NSInteger {
    case today = 0
    case yesterday
    case custom
}

class PfpSelectDateCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var accView: UIImageView!
    
    var type: DateSelectionType = .today
    var dateFormatter:DateFormatter = DateFormatter()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "d MMMM"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateWithType (_ type:DateSelectionType, isSelected:Bool, selectedType: DateSelectionType, date:Date?) {
        self.accView.image = UIImage.init(named: "verified")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.accView.tintColor = UIColor.white
        self.type = type
        self.accView.layer.cornerRadius = 11
        
        if isSelected {
            self.accView.layer.borderWidth = 0
            self.accView.backgroundColor = ApplicationTheme.shared().primaryNavigationBarTintColor
            self.nameLabel.font = UIFont.SFUIText(size: 15, type: UIFont.SFUITextFontType.bold)
        } else {
            self.accView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
            self.accView.layer.borderWidth = 2
            self.accView.backgroundColor = UIColor.white
            self.nameLabel.font = UIFont.SFUIText(size: 15, type: UIFont.SFUITextFontType.semibold)
        }
        
        switch type {
        case .today:
            self.nameLabel.text = String.localized("today").capitalized
        case .yesterday:
            self.nameLabel.text = String.localized("yesterday").capitalized
        default:
            if selectedType == type && isSelected {
                self.nameLabel.text = "\(dateFormatter.string(from: date!).capitalized)"
            } else {
                self.nameLabel.text = String.localized("other_date").capitalized
            }
        }
    }
}
