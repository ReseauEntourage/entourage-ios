//
//  OTCustomPageControl.swift
//  entourage
//
//  Created by Jr on 10/04/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

@IBDesignable
class MJCustomPageControl:  UIPageControl {
    
    @IBInspectable var currentPageDotImage: UIImage?
    @IBInspectable var otherPageDotImage: UIImage?
        
    @IBInspectable private var currentColor:UIColor = .appOrange {
        didSet {
            updateDots()
        }
    }
    
    @IBInspectable private var otherColor:UIColor = .lightGray {
        didSet {
            updateDots()
        }
    }
    
    override var numberOfPages: Int {
        didSet {
            updateDots()
        }
    }
    
    override var currentPage: Int {
        didSet {
            updateDots()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 14.0, *) {
            pageIndicatorTintColor = otherColor
            currentPageIndicatorTintColor = currentColor
            return
        }
        pageIndicatorTintColor = .clear
        currentPageIndicatorTintColor = .clear
        clipsToBounds = false
    }
    
    func setColorsDots(colorSelected:UIColor, colorUnselected:UIColor) {
        currentColor = colorSelected
        otherColor = colorUnselected
    }
    
    private func updateDots() {
        var dotViews: [UIView] = subviews
        if #available(iOS 14, *) {
            let pageControl = dotViews[0]
            let dotContainerView = pageControl.subviews[0]
            dotViews = dotContainerView.subviews
        }
        
        for (index, subview) in dotViews.enumerated() {
            let imageView: UIImageView
            if let existingImageview = getImageView(forSubview: subview) {
                imageView = existingImageview
            }
            else {
                imageView = UIImageView(image: otherPageDotImage)
                imageView.center = subview.center
                subview.addSubview(imageView)
                subview.clipsToBounds = false
            }
            imageView.image = currentPage == index ? currentPageDotImage : otherPageDotImage
        }
    }
    
    private func getImageView(forSubview view: UIView) -> UIImageView? {
        if let imageView = view as? UIImageView {
            return imageView
        }
        else {
            let view = view.subviews.first { (view) -> Bool in
                return view is UIImageView
            } as? UIImageView
            
            return view
        }
    }
}
