//
//  EventParamEditShow.swift
//  entourage
//
//  Created by Jerome on 25/07/2022.
//

import UIKit

class EventParamEditShow: UITableViewCell {


    @IBOutlet weak var ui_image_arrow: UIImageView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_separator: UIView!
    
    weak var delegate:EventParamCellDelegate? = nil
    
    var cellType:EventCellEditType = .CGU
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontH2Noir())
    }
    
    func populateCell(title:String,imageName:String? = nil,showArrow:Bool = true, showSeparator:Bool = true, delegate:EventParamCellDelegate, type:EventCellEditType) {
        self.delegate = delegate
        self.cellType = type
        
        ui_title.text = title
        if let imageName = imageName {
            ui_image.image = UIImage.init(named: imageName)
        }
        
        ui_image_arrow.isHidden = !showArrow
        ui_separator.isHidden = !showSeparator
    }
    
    @IBAction func action_show(_ sender: Any) {
        switch cellType {
        case .CGU:
            delegate?.showCGU()
        case .EditEvent:
            delegate?.editEvent()
        case .EditRecurrency:
            delegate?.editRecurrency()
        }
    }
}
