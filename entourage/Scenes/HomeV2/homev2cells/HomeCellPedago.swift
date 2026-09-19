//
//  HomeCellPedago.swift
//  entourage
//
//  Created by Clement entourage on 04/10/2023.
//

import Foundation
import UIKit
import SDWebImage

class HomeCellPedago:UITableViewCell{
    
    //OUTLET
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_view_tag_container: UIView!
    @IBOutlet weak var ui_label_pedago: UILabel!
    @IBOutlet weak var ui_label_title: UILabel!
    
    @IBOutlet weak var ui_label_duration: UILabel!
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor(named: "white_orange_home")
        containerView.layer.cornerRadius = 15
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.appBeige.cgColor
        containerView.clipsToBounds = true

        ui_view_tag_container.setContentHuggingPriority(.required, for: .horizontal)
        ui_label_pedago.setContentHuggingPriority(.required, for: .horizontal)
        ui_label_pedago.setContentCompressionResistancePriority(.required, for: .horizontal)

        repositionDurationLabel()
    }

    private func repositionDurationLabel() {
        guard let tagContainer = ui_view_tag_container else { return }

        // Remove existing constraints on ui_label_duration
        // It's a direct child of containerView, so constraints are held by containerView
        let constraintsToRemove = containerView.constraints.filter { constraint in
            return (constraint.firstItem as? UIView == ui_label_duration && (constraint.firstAttribute == .bottom || constraint.firstAttribute == .leading)) ||
                   (constraint.secondItem as? UIView == ui_label_duration && (constraint.secondAttribute == .bottom || constraint.secondAttribute == .leading))
        }
        containerView.removeConstraints(constraintsToRemove)

        ui_label_duration.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ui_label_duration.leadingAnchor.constraint(equalTo: tagContainer.trailingAnchor, constant: 10),
            ui_label_duration.centerYAnchor.constraint(equalTo: tagContainer.centerYAnchor)
        ])
    }
    
    func configure(pedago:PedagogicResource){
        ui_label_title.text = pedago.title
        if let imageUrl = pedago.imageUrl, let url = URL(string: imageUrl) {
            ui_image.sd_setImage(with: url, placeholderImage:UIImage(named: "placeholder_action"))
        }
        else {
            ui_image.image = UIImage(named: "placeholder_action")
        }

        switch pedago.tag {
        case .All:
            ui_label_pedago.text = "home_v2_pedago_item_tag_all".localized
            ui_label_pedago.textColor = UIColor.appOrangeLight
            ui_view_tag_container.backgroundColor = UIColor.appBeigeLighter
        case .Understand:
            ui_label_pedago.text = "home_v2_pedago_item_tag_understand".localized
            ui_label_pedago.textColor = UIColor.appTagUnderstand
            ui_view_tag_container.backgroundColor = UIColor.appTagUnderstandBackground
        case .Act:
            ui_label_pedago.text = "home_v2_pedago_item_tag_act".localized
            ui_label_pedago.textColor = UIColor.appTagAct
            ui_view_tag_container.backgroundColor = UIColor.appTagActBackground
        case .Inspire:
            ui_label_pedago.text = "home_v2_pedago_item_tag_inspire".localized
            ui_label_pedago.textColor = UIColor.appTagInspire
            ui_view_tag_container.backgroundColor = UIColor.appTagInspireBackground
        case .None:
            ui_label_title.text = "Autre"
            ui_label_pedago.textColor = UIColor.appOrangeLight
            ui_view_tag_container.backgroundColor = UIColor.appBeigeLighter
        }

        if let _duration = pedago.duration, _duration > 0 {
            ui_label_duration.isHidden = false
            let durationText = String(format: "home_v2_pedag_item_lenght_title".localized, _duration)

            // Add clock icon using NSTextAttachment
            let attachment = NSTextAttachment()
            if let image = UIImage(systemName: "clock")?.withTintColor(.black, renderingMode: .alwaysOriginal) {
                attachment.image = image
                attachment.bounds = CGRect(x: 0, y: -2, width: 12, height: 12)
            }
            let completeText = NSMutableAttributedString(attachment: attachment)
            completeText.append(NSAttributedString(string: " " + durationText))
            ui_label_duration.attributedText = completeText
        } else {
            ui_label_duration.isHidden = true
        }
    }
}
