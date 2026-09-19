//
//  HomeCellClimatisation.swift
//  entourage
//
//  Created by Clement entourage on 08/07/2026.
//

import Foundation
import UIKit

class HomeCellClimatisation: UITableViewCell {

    //OUTLET
    @IBOutlet weak var ui_gradient_view: UIView!
    @IBOutlet weak var ui_image_icon: UIImageView!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_subtitle: UILabel!
    @IBOutlet weak var ui_label_badge: UILabel!

    //VAR
    class var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor(named: "white_orange_home")
        self.ui_image_icon.image = UIImage(named: "picto_ac_unit")
    }

    func configure(title: String, subtitle: String, badge: String) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = ui_gradient_view.bounds

        let color1 = UIColor(hexString: "#F55F24")
        let color2 = UIColor(hexString: "#FF9C5D")

        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        ui_gradient_view.layer.insertSublayer(gradientLayer, at: 0)

        self.ui_label_title.text = title
        self.ui_label_subtitle.text = subtitle
        self.ui_label_badge.text = badge
    }
}
