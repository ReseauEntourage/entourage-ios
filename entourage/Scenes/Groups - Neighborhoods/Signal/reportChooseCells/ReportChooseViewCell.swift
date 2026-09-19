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
    case translate
    case copy
    case edit
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
        self.ui_title?.numberOfLines = 0 
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
        case .translate:
            ui_image?.image = UIImage(named: "ic_translation")
            ui_title?.text = "report_modal_title_translate".localized
            ui_subtitle?.text = "report_modal_subtitle_translate".localized
        case .copy:
            ui_image?.image = UIImage(named: "ic_copy")
            ui_title?.text = "copy_the_text".localized
            ui_subtitle?.text = "copy_the_text_explanation".localized
        case .edit:
            // L'icône source a un trait blanc (prévue pour un fond coloré) : on la force en
            // template pour la teinter en orange, cohérent avec les autres lignes du menu.
            ui_image?.image = UIImage(named: "ic_profil_full_pen")?.withRenderingMode(.alwaysTemplate)
            ui_image?.tintColor = .appOrange
            ui_title?.text = "modify".localized
            ui_subtitle?.text = "edit_message_cell_subtitle".localized
        }
    }
}
