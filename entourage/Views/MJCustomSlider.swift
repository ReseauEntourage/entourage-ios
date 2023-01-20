//
//  MJCustomSlider.swift
//  entourage
//
//  Created by Jerome on 23/03/2022.
//

import Foundation



@IBDesignable
class MJCustomSlider: UISlider {
    @IBInspectable var trackHeight: CGFloat = 17 //Track Height mandatory
    
    @IBInspectable var thumbImage: UIImage? = nil {
        didSet {
            setThumbImage(thumbImage, for: .normal)
        }
    }
    
    let minPercent:Float = 5 //To prevent text position outside progress left
    let maxPercent:Float = 90 //To avoid text position outside screen right
    weak var delegate:MJCustomSliderDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let thumbImage = thumbImage {
            setThumbImage(thumbImage, for: .normal)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setValue()
        
        //Fix Round left / right when overriding height
        if #available(iOS 14.0, *) {
            if let layers = layer.sublayers?.first?.sublayers, layers.count > 0 {
                let layer = layers[1]
                layer.cornerRadius = layer.bounds.height / 2
            }
        } else {
            if let layers = layer.sublayers, layers.count > 0 {
                let layer = layers[1]
                layer.cornerRadius = layer.bounds.height / 2
            }
        }
    }
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newRect = super.trackRect(forBounds: bounds)
        newRect.size.height = trackHeight
        return newRect
    }
    
    func getPercentScreenPosition() -> CGFloat {
        let currentPercent = (self.value / maximumValue) * 100
        let minimalProgress = currentPercent <= minPercent ? minPercent : currentPercent > maxPercent ? maxPercent : currentPercent
        
        let _progressCalculated = (frame.width / 100.0) * CGFloat( minimalProgress)
        return _progressCalculated
    }
    
    func setupSlider(delegate:MJCustomSliderDelegate, imageThumb:UIImage? = nil, minValue:Float,maxValue:Float) {
        self.delegate = delegate
        self.thumbImage = imageThumb
        self.maximumValue = maxValue
        self.minimumValue = minValue
    }
    
    private func setValue() {
        delegate?.updateLabel()
    }
}

//MARK: - Protocol -
protocol MJCustomSliderDelegate:AnyObject {
    func updateLabel()
}
