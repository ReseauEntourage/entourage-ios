//
//  HomeCellActionCollectionViewCell.swift
//  entourage
//
//  Created by Clement entourage on 13/10/2023.
//

import UIKit
import SDWebImage

class HomeCellActionCollectionViewCell: UICollectionViewCell {

    // OUTLET
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ui_image_user: UIImageView!
    @IBOutlet weak var ui_label_username: UILabel!
    @IBOutlet weak var ui_view_tag: UIView!
    @IBOutlet weak var ui_label_tag: UILabel!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    @IBOutlet weak var ui_image_pin: UIImageView!
    @IBOutlet weak var ui_label_distance: UILabel!

    // VARIABLE
    class var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    func setupUI() {
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.appBeige.cgColor
        containerView.backgroundColor = .white

        ui_image_user.layer.cornerRadius = ui_image_user.frame.height / 2
        ui_image_user.layer.borderWidth = 1
        ui_image_user.layer.borderColor = UIColor.appOrange.cgColor
        ui_image_user.clipsToBounds = true

        ui_view_tag.layer.cornerRadius = ui_view_tag.frame.height / 2
        ui_view_tag.backgroundColor = UIColor.appBeige

        ui_label_username.font = UIFont(name: "Quicksand-Bold", size: 15)
        ui_label_username.textColor = .black

        ui_label_tag.font = UIFont(name: "NunitoSans-Regular", size: 11)
        ui_label_tag.textColor = UIColor.appOrange

        ui_label_title.font = UIFont(name: "Quicksand-Bold", size: 15)
        ui_label_title.textColor = .black
        ui_label_title.numberOfLines = 2

        ui_label_description.font = UIFont(name: "NunitoSans-Regular", size: 13)
        ui_label_description.textColor = UIColor(named: "grey_light")
        ui_label_description.numberOfLines = 3

        ui_label_distance.font = UIFont(name: "NunitoSans-Regular", size: 11)
        ui_label_distance.textColor = UIColor.appOrange

        ui_image_pin.tintColor = UIColor.appOrange
    }

    func configure(action: Action) {
        // User Image
        if let imageUrl = action.author?.avatarURL, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            ui_image_user.sd_setImage(with: mainUrl, placeholderImage: UIImage(named: "placeholder_user"))
        } else {
            ui_image_user.image = UIImage(named: "placeholder_user")
        }

        // Username
        ui_label_username.text = action.author?.displayName ?? "-"

        // Tag
        if let sectionName = action.sectionName {
            ui_label_tag.text = TagsUtils.showTagTranslated(sectionName)
        } else {
            ui_label_tag.text = "-"
        }

        // Title
        ui_label_title.text = action.title

        // Description
        if let desc = action.description, !desc.isEmpty {
            let first = String(desc.prefix(1)).uppercased()
            let other = String(desc.dropFirst())
            ui_label_description.text = first + other
        } else {
            ui_label_description.text = ""
        }

        // Distance
        if let distance = action.distance {
            var distString = Utils.displayDistance(distance: distance)
            if distString.lowercased().hasPrefix("à ") {
                distString = String(distString.dropFirst(2))
            }
            ui_label_distance.text = distString
            ui_image_pin.isHidden = false
        } else {
            ui_label_distance.text = "-"
            ui_image_pin.isHidden = false
        }
    }
}
