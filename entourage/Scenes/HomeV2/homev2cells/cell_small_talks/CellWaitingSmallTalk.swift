//
//  CellWaitingSmallTalk.swift
//  entourage
//
//  Created by Clement entourage on 14/05/2025.
//

import Foundation
import UIKit

class CellWaitingSmallTalk:UICollectionViewCell {
    
    //OUTLET
    @IBOutlet weak var ui_iv_waiting: UIImageView!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_subtitle: UILabel!
    
    //VARIABLE
    
    
    override func awakeFromNib() {
        ui_label_title.text = "small_talk_title_waiting".localized
        ui_label_title.setFontTitle(size: 15)
        ui_label_subtitle.text = "small_talk_subtitle_waiting".localized
        ui_label_subtitle.setFontBody(size: 15)
    }
    
    
    
}
