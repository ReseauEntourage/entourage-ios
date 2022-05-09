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
    
    override func draw(_ rect: CGRect) {
        addShadow()
    }
    
    private func addShadow() {
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.path = createPath()
        shapeLayer.fillColor = color?.cgColor ?? UIColor.white.cgColor
        shapeLayer.shadowColor = UIColor.appOrange.cgColor
        shapeLayer.shadowOffset = CGSize(width: 0   , height: -3);
        shapeLayer.shadowOpacity = 0.17
        shapeLayer.shadowPath =  UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        
        
        if let oldShapeLayer = self.shapeLayer {
            layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            layer.insertSublayer(shapeLayer, at: 0)
        }
        
        self.shapeLayer = shapeLayer
        
        let itemsCount = items?.count ?? 1
        selectionIndicatorImage = createSelectionIndicator(color: UIColor.appOrange, size: CGSize(width: frame.width/CGFloat(itemsCount), height: frame.height), lineWidth: 1)
    }
    
    private func createSelectionIndicator(color: UIColor, size: CGSize, lineWidth: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: lineWidth))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func createPath() -> CGPath {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: 0.0))
        
        return path.cgPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.isTranslucent = true
        var _frame = self.frame
        _frame.size.height = tabHeight + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? CGFloat.zero)
        _frame.origin.y = self.frame.origin.y +   ( self.frame.height - tabHeight - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? CGFloat.zero))
        self.frame = _frame
    }
}
