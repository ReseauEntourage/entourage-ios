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
        self.dateFormatter.locale = Locale.init(identifier: "fr_FR")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateWithType (_ type:DateSelectionType, isSelected:Bool, selectedType: DateSelectionType, date:Date?) {
        self.accView.image = UIImage.init(named: "verified")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.accView.tintColor = UIColor.white
        self.type = type
        self.accView.layer.cornerRadius = 11
        
        if isSelected {
            self.accView.layer.borderWidth = 0
            self.accView.backgroundColor = ApplicationTheme.shared().primaryNavigationBarTintColor
        } else {
            self.accView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
            self.accView.layer.borderWidth = 2
            self.accView.backgroundColor = UIColor.white
        }
        
        switch type {
        case .today:
            self.nameLabel.text = String.localized("today").lowercased()
        case .yesterday:
            self.nameLabel.text = String.localized("yesterday").lowercased()
        default:
            if selectedType == type && isSelected {
                self.nameLabel.text = "le \(dateFormatter.string(from: date!).lowercased())"
            } else {
                self.nameLabel.text = String.localized("pfp_date_title").lowercased()
            }
        }
    }
}
