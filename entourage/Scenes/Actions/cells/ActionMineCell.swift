//
//  ActionMineCell.swift
//  entourage
//
//  Created by Jerome on 04/08/2022.
//

import UIKit
import SDWebImage

class ActionMineCell: UITableViewCell {

    @IBOutlet weak var ui_picto: UIImageView!
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_date: UILabel!
    @IBOutlet weak var ui_view_separator: UIView!
    
    @IBOutlet weak var ui_constraint_picto_width: NSLayoutConstraint!
    
    let sizePicto:CGFloat = 20
    let sizePlaceholder:CGFloat = 50
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_date.setupFontAndColor(style: ApplicationTheme.getFontLegendGris())
        
        ui_image.layer.cornerRadius = 8
    }
    
    func populateCell(action:Action) {
        
        ui_title.text = action.title
        
        if let imageUrl = action.imageUrl, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            ui_image.sd_setImage(with: mainUrl, placeholderImage: nil, options:SDWebImageOptions(rawValue: SDWebImageOptions.progressiveLoad.rawValue), completed: { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
                if error != nil {
                    self?.addActionType(sectionName: action.sectionName)
                }
            })
        }
        else {
            self.addActionType(sectionName: action.sectionName)
        }
        
        ui_date.text = action.getCreatedDate()
    }
    
    private func addActionType(sectionName:String?) {
        if let sectionName = sectionName, let imgStr = Metadatas.sharedInstance.tagsSections?.getSectionFrom(key: sectionName)?.getImageName() {
            ui_constraint_picto_width.constant = sizePicto
            ui_picto.image = UIImage.init(named: imgStr)
            ui_image.image = nil
        }
        else {
            ui_constraint_picto_width.constant = sizePlaceholder
            ui_picto.image = UIImage.init(named: "ic_placeholder_action")
        }
    }
}
