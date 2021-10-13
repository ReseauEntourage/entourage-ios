//
//  OTMyActionTableViewCell.swift
//  entourage
//
//  Created by Jerome on 13/10/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTMyActionTableViewCell: UITableViewCell {
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_label_location: UILabel!
    @IBOutlet weak var ui_label_info: UILabel!
    @IBOutlet weak var ui_image_info: UIImageView!
    @IBOutlet weak var ui_view_container: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_view_container.layer.cornerRadius = 4
    }

    func populateCell(entourage:OTEntourage) {
        ui_title.text = entourage.title
        
        let cat = getCat(type: entourage.type, category: entourage.category)
        ui_label_info.text = cat.title
        
        if let pictoStr = OTAppAppearance.iconName(forEntourageItem: entourage, isAnnotation: false) {
            ui_image_info.image = UIImage.init(named: pictoStr)
        }
        
        let distance = HomeCellUtils.getDistance(item: entourage)
        var distanceStr = ""
        
        if distance < 1000000 {
            distanceStr = HomeCellUtils.formattedItemDistance(distance: distance)
            if distanceStr.count > 0 {
                distanceStr = String.init(format: "%@ - ", distanceStr)
            }
        }
        else {
            distanceStr = ""
        }
        let _location = String.init(format: "%@%@", distanceStr,entourage.postalCode)
        ui_label_location.text = _location.count == 0 ? " " : _location
    }
    
    func getCat(type:String,category:String) -> OTCategory {
        var cat = OTCategory.init()
        if let _array = OTCategoryFromJsonService.getData() as? [OTCategoryType] {
            
            for item in _array {
                if item.type == type {
                    for _item2 in item.categories {
                        if let _cat = _item2 as? OTCategory {
                            if _cat.category == category {
                                cat = _cat
                                break
                            }
                        }
                    }
                    break
                }
            }
        }
        return cat
    }
}
