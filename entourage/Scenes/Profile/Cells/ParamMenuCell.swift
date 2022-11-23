//
//  MainParamCell.swift
//  entourage
//
//  Created by Jerome on 14/03/2022.
//

import UIKit

class ParamMenuCell: UITableViewCell {
    
    @IBOutlet weak var ui_view_notifs: UIView!
    @IBOutlet weak var ui_title_notifs: UILabel!
    
    @IBOutlet weak var ui_view_help: UIView!
    @IBOutlet weak var ui_title_help: UILabel!
    
    @IBOutlet weak var ui_view_unlock_members: UIView!
    @IBOutlet weak var ui_title_unlock_members: UILabel!
    
    @IBOutlet weak var ui_view_share: UIView!
    @IBOutlet weak var ui_title_share: UILabel!
    
    @IBOutlet weak var ui_view_logout: UIView!
    @IBOutlet weak var ui_title_logout: UILabel!
    
    @IBOutlet weak var ui_view_suppress_account: UIView!
    @IBOutlet weak var ui_title_suppress_account: UILabel!
    
    weak var delegate:MainParamsMenuDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_title_notifs.text = "params_notifs".localized
        ui_title_help.text = "params_help".localized
        ui_title_unlock_members.text = "params_unlock".localized
        ui_title_share.text = "params_share".localized
        ui_title_logout.text = "params_logout".localized
        ui_title_suppress_account.text = "params_suppress".localized
        
        setLabelTitle(label: ui_title_notifs)
        setLabelTitle(label: ui_title_help)
        setLabelTitle(label: ui_title_unlock_members)
        setLabelTitle(label: ui_title_share)
        
        ui_title_logout.textColor = .appOrange
        ui_title_logout.font = ApplicationTheme.getFontNunitoBold(size: 15)
        
        ui_title_suppress_account.textColor = .appOrange
        ui_title_suppress_account.font = ApplicationTheme.getFontCourantBoldOrangeClair().font
        
        //MARK: - menu hidden for V8 -
        ui_view_unlock_members.isHidden = true
    }
    
    private func setLabelTitle(label:UILabel) {
        label.font = ApplicationTheme.getFontH2Noir().font
        label.textColor = .black
    }
    
    func populateCell(delegate:MainParamsMenuDelegate) {
        self.delegate = delegate
    }
    
    //MARK: - IBActions -
    @IBAction func action_show_notif(_ sender: Any) {
        delegate?.actionMenu(type: .Notifs)
    }
    @IBAction func action_show_help(_ sender: Any) {
        delegate?.actionMenu(type: .Help)
    }
    @IBAction func action_show_unlock(_ sender: Any) {
        delegate?.actionMenu(type: .Unlock)
    }
    @IBAction func action_share(_ sender: Any) {
        delegate?.actionMenu(type: .Share)
    }
    @IBAction func action_logout(_ sender: Any) {
        delegate?.actionMenu(type: .Logout)
    }
    @IBAction func action_suppress_account(_ sender: Any) {
        delegate?.actionMenu(type: .Suppress)
    }
}

//MARK: - MainParamsMenuType -
enum MainParamsMenuType {
    case Notifs
    case Help
    case Unlock
    case Share
    case Logout
    case Suppress
}

//MARK: - MainParamsMenuDelegate -
protocol MainParamsMenuDelegate: AnyObject {
    func actionMenu(type:MainParamsMenuType)
}
