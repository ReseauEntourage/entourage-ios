//
//  NeighborhoodParamEditShowCell.swift
//  entourage
//
//  Created by Jerome on 03/05/2022.
//

import UIKit

class NeighborhoodParamEditShowCell: UITableViewCell {

    @IBOutlet weak var ui_image_arrow: UIImageView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_separator: UIView!
    
    weak var delegate:NeighborhoodParamCellDelegate? = nil
    
    var isCGU = false
    var isShare = false
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontH2Noir())
    }
    
    func populateCell(title:String,imageName:String? = nil,showArrow:Bool = true, showSeparator:Bool = true, delegate:NeighborhoodParamCellDelegate, isCGU:Bool, isShare:Bool) {
        self.delegate = delegate
        self.isCGU = isCGU
        self.isShare = isShare
        if isShare {
            ui_image.tintColor = UIColor.appOrange
        }
        
        ui_title.text = title
        if let imageName = imageName {
            ui_image.image = UIImage.init(named: imageName)
        }
        
        ui_image_arrow.isHidden = !showArrow
        ui_separator.isHidden = !showSeparator
    }
    
    @IBAction func action_show(_ sender: Any) {
        if isCGU {
            delegate?.showCGU()
        }else if isShare {
            delegate?.shareGroup()
        }else {
            delegate?.editGroup()
        }
    }
}
