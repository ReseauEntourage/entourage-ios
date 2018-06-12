//
//  PpfUserCircleCell.swift
//  pfp
//
//  Created by Smart Care on 04/06/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import UIKit

class PfpUserCircleCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var accView: UIImageView!
    
    let iconCornerRadius:CGFloat = 25
    let iconBorderWidth:CGFloat = 2

    override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.layer.cornerRadius = iconCornerRadius
        iconImageView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        iconImageView.layer.borderWidth = iconBorderWidth
        
        self.accView.image = UIImage.init(named: "verified")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.accView.tintColor = UIColor.white
        self.accView.layer.cornerRadius = 11
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateWithUserCircle (_ circle:OTUserMembershipListItem) {
        
        if circle.isSelected {
            self.accView.layer.borderWidth = 0
            self.accView.backgroundColor = ApplicationTheme.shared().primaryNavigationBarTintColor
        } else {
            self.accView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
            self.accView.layer.cornerRadius = 11
            self.accView.layer.borderWidth = iconBorderWidth
            self.accView.backgroundColor = UIColor.white
        }
        
        self.nameLabel.text = circle.title
    }

}
