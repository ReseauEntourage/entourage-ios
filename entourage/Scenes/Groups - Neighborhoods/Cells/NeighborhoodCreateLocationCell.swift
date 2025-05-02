//
//  NeighborhoodInputButtonTextTableViewCell.swift
//  entourage
//
//  Created by Jerome on 07/04/2022.
//

import UIKit

class NeighborhoodCreateLocationCell: UITableViewCell {
    
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_description: UILabel!
    @IBOutlet weak var ui_info: UILabel!
    
    @IBOutlet weak var ui_view_error: MJErrorInputTextView!
    
    weak var delegate:NeighborhoodCreateLocationCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let stringAttr = Utils.formatString(messageTxt: "neighborhoodCreatePlaceTitle".localized, messageTxtHighlight: "neighborhoodCreatePlaceSubtitle".localized, fontColorType: ApplicationTheme.getFontH2Noir(size: 15), fontColorTypeHighlight: ApplicationTheme.getFontLegend(size: 13))
        ui_title.attributedText = stringAttr
        
        ui_description.text = "neighborhoodCreatePlaceDescription".localized
        ui_description.font = ApplicationTheme.getFontLegend(size: 11).font
        ui_description.textColor = ApplicationTheme.getFontLegend(size: 11).color
        
        ui_info.text = "neighborhoodCreatePlaceInfos".localized
        ui_info.font = ApplicationTheme.getFontChampDefault(size: 13).font
        ui_info.textColor = ApplicationTheme.getFontChampDefault(size: 13).color
        ui_view_error.isHidden = true
    }
    
    func populateCell(delegate:NeighborhoodCreateLocationCellDelegate, showError:Bool, cityName:String?, title:String? = nil, description:String? = nil) {
        self.delegate = delegate
        
        if let title = title {
            ui_title.text = title
        }
        
        if let description = description {
            ui_description.text = description
        }
        
        ui_view_error.isHidden = !showError
        if let cityName = cityName {
            ui_info.text = cityName
            ui_info.textColor = .black
        }
        else {
            ui_info.textColor = .appGrisSombre40
        }
    }
    
    @IBAction func action_select_location(_ sender: Any) {
        delegate?.showSelectLocation()
    }
}

//MARK: - Protocol NeighborhoodCreateLocationCellDelegate -
protocol NeighborhoodCreateLocationCellDelegate:AnyObject {
    func showSelectLocation()
}
