//
//  HomeCellMapButton.swift
//  entourage
//
//  Created by Clement entourage on 03/10/2023.
//

import Foundation
import UIKit

class HomeCellMapButton:UITableViewCell{
    
    //OUTLET
    @IBOutlet weak var ui_gradient_view: UIView!
    @IBOutlet weak var ui_image_map: UIImageView!
    @IBOutlet weak var ui_label_title: UILabel!
    
    @IBOutlet weak var ui_image_arrow: UIImageView!
    //VAR
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        self.contentView.backgroundColor = UIColor(named: "white_orange_home")

    }
    
    func configure(title:String){
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = ui_gradient_view.bounds

        // Convertir les valeurs hexadécimales en UIColor
        let color1 = UIColor(hexString: "#F55F24")
        let color2 = UIColor(hexString: "#FF9C5D")

        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        ui_gradient_view.layer.insertSublayer(gradientLayer, at: 0)

        self.ui_label_title.text = title
    }
    
}
