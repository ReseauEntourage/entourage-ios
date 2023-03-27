//
//  ReportChooseViewCell.swift
//  entourage
//
//  Created by Clement entourage on 27/02/2023.
//

import Foundation
import UIKit

enum ReportCellType {
    case report
    case suppress
}

class ReportChooseViewCell:UITableViewCell {
    //OUTLET
    @IBOutlet weak var ui_image: UIImageView?
    @IBOutlet weak var ui_title: UILabel?
    @IBOutlet weak var ui_subtitle: UILabel?
    //VARIABLE
    var type:ReportCellType = .report
    
    static var nib: UINib {
        return UINib(nibName: "ReportChooseViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        ui_image?.image = UIImage(named: "ic_report")
        ui_title?.text = "report_post_cell_title".localized
        ui_subtitle?.text = "report_post_cell_subtitle".localized
    }
    
    func populate(type:ReportCellType){
        self.type = type
        switch(type) {
        case .report:
            ui_image?.image = UIImage(named: "ic_report")
            ui_title?.text = "report_post_cell_title".localized
            ui_subtitle?.text = "report_post_cell_subtitle".localized
        case .suppress:
            ui_image?.image = UIImage(named: "ic_supress")
            ui_title?.text = "suppress_post_cell_title".localized
            ui_subtitle?.text = "suppress_post_cell_subtitle".localized
        }
    }
    
    func populateForTest(){
        ui_image?.image = UIImage(named: "ic_supress")
        ui_title?.text = "suppress_post_cell_title".localized
        ui_subtitle?.text = "suppress_post_cell_subtitle".localized
    }
    
}
