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
    var paramType:ParamSupressType = .publication
    
    static var nib: UINib {
        return UINib(nibName: "ReportChooseViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        ui_image?.image = UIImage(named: "ic_report")
        ui_title?.text = "report_post_cell_title".localized
        ui_subtitle?.text = "report_post_cell_subtitle".localized
    }
    
    func populate(type:ReportCellType, paramType:ParamSupressType){
        print(paramType)
        self.type = type
        self.paramType = paramType
        var title = ""
        var subtitle = ""
        var reportsubtitle = ""
        switch(paramType){
        case .message:
            title = "suppress_message_cell_title".localized
            subtitle = "suppress_message_cell_subtitle".localized
            reportsubtitle = "report_message_cell_subtitle".localized

        case .commment:
            title = "suppress_comment_cell_title".localized
            subtitle = "suppress_comment_cell_subtitle".localized
            reportsubtitle = "report_comment_cell_subtitle".localized

        case .publication:
            title = "suppress_post_cell_title".localized
            subtitle = "suppress_post_cell_subtitle".localized
            reportsubtitle = "report_post_cell_subtitle".localized
        case .action:
            title = "suppress_post_cell_title".localized
            subtitle = "report_action_cell_subtitle".localized
            reportsubtitle = "report_action_cell_subtitle".localized
        }
        
        
        switch(type) {
        case .report:
            ui_image?.image = UIImage(named: "ic_report")
            ui_title?.text = "report_post_cell_title".localized
            ui_subtitle?.text = reportsubtitle
        case .suppress:
            ui_image?.image = UIImage(named: "ic_supress")
            ui_title?.text = title
            ui_subtitle?.text = subtitle
        }
    }
}
