//
//  DiscussionEventCell.swift
//  entourage
//
//  Created by Clement entourage on 10/03/2025.
//

import Foundation
import UIKit

protocol DiscussionEventCellDelegate {
    func onDiscussionEventClick()
}
class DiscussionEventCell:UITableViewCell {
    
    //OUTLET
    @IBOutlet weak var ui_label: UILabel!
    @IBOutlet weak var ui_view: UIView!
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    var delegate:DiscussionEventCellDelegate?
    
    override func awakeFromNib() {
        ui_label.text = "event_discut_title".localized
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap))
        ui_view.addGestureRecognizer(tapGesture)
        ui_view.isUserInteractionEnabled = true
    }
    
    @objc private func handleViewTap() {
        delegate?.onDiscussionEventClick()
    }
    
}
