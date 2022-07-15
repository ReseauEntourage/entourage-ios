//
//  EventDetailFullGroupCell.swift
//  entourage
//
//  Created by Jerome on 12/07/2022.
//

import UIKit

class EventDetailFullGroupCell: UITableViewCell {

    class var identifier:String {return String(describing: self) }

    @IBOutlet weak var ui_title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title?.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
    }

    func populateCell(title:String?) {
        let _title:String = title ?? "-"
        ui_title.attributedText = Utils.formatStringUnderline(textString: _title, textColor: .black,font: ApplicationTheme.getFontNunitoRegular(size: 15))
    }
 }
