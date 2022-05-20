//
//  MJShadowBottomView.swift
//  entourage
//
//  Created by Jerome on 20/05/2022.
//

import Foundation

class MJShadowBottomView: UIView {
    
    var setupShadowDone: Bool = false
    
    public func setupShadow() {
        if setupShadowDone { return }
        
        self.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: ApplicationTheme.bigCornerRadius, height: ApplicationTheme.bigCornerRadius)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        setupShadowDone = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupShadow()
    }
}
