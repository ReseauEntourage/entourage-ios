//
//  MJTabbarCustom.swift
//  entourage
//
//  Created by Jerome on 09/05/2022.
//

import UIKit

class MJTabbarCustom: UITabBar {
    var color: UIColor?
    var radius: CGFloat = 0
    
    let tabHeight:CGFloat = 49
    private var shapeLayer: CALayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadow()
    }
    
    private func addShadow() {
        self.layer.shadowColor = UIColor.appOrange.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: -3)
        self.layer.shadowOpacity = 0.17
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.isTranslucent = true
    }
}
