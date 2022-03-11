//
//  Extensions_UIImage.swift
//  entourage
//
//  Created by Jerome on 01/03/2022.
//

import UIKit

extension UIImage {
    
    func toSquare() -> UIImage? {
        let size = max(self.size.width, self.size.height)
        let diff = abs(self.size.width - self.size.height) / 2
        var x:CGFloat = 0
        var y:CGFloat = 0
    
        if self.size.width > self.size.height {
            y = diff
        }
        else {
            x = diff
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 1.0)
        
        self.draw(in: CGRect(x: x, y: y, width: self.size.width, height: self.size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func resizeTo(size:CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
