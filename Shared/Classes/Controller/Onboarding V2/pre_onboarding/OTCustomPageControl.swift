//
//  OTCustomPageControl.swift
//  entourage
//
//  Created by Jr on 10/04/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit

@IBDesignable
class OTCustomPageControl:  UIPageControl {
    
    @IBInspectable var currentPageDotImage: UIImage?
    @IBInspectable var otherPageDotImage: UIImage?
    
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
        pageIndicatorTintColor = .clear
        currentPageIndicatorTintColor = .clear
        clipsToBounds = false
    }
    
    private func updateDots() {
        
        for (index, subview) in subviews.enumerated() {
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
