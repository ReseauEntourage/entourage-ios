//
//  ProgressRadiusView.swift
//  entourage
//
//  Created by Jerome on 09/03/2022.
//

import UIKit

//MARK: - ProgressRadiusView -
class ProgressRadiusView: UIView {
    var progressPercent:CGFloat = 50
    private var currentPercentPosition:CGFloat = 0
    
    private let minPercent:CGFloat = 5 //To prevent text position outside progress left
    private let maxPercent:CGFloat = 80 //To avoid text position outside screen right
    
    override func draw(_ rect: CGRect) {
        drawBar(frame: rect, progress: progressPercent)
    }
    
    func getPercentScreenPosition() -> CGFloat {
        let minimalProgress = progressPercent <= minPercent ? minPercent : progressPercent > maxPercent ? maxPercent : progressPercent
        let _progressCalculated = (frame.width / 100.0) * minimalProgress
        return _progressCalculated
    }
    
    private func drawBar(frame: CGRect = CGRect(x: 0, y: 0, width: 240, height: 18), progress: CGFloat = 50) {
        // General Declarations
        let context = UIGraphicsGetCurrentContext()!
        // This non-generic function dramatically improves compilation times of complex expressions.
        func fastFloor(_ x: CGFloat) -> CGFloat { return floor(x) }

        // Color Declarations
        let color_bg = UIColor.appOrangeLight_50
        let color_active = UIColor.appOrange
        let _height = frame.height

        //progressBackground Drawing
        let progressBackgroundPath = UIBezierPath(roundedRect: CGRect(x: frame.minX + fastFloor(frame.width * 0.00000 + 0.5), y: frame.minY, width: fastFloor(frame.width * 1.00000 + 0.5) - fastFloor(frame.width * 0.00000 + 0.5), height: frame.height), cornerRadius: _height / 2)
        color_bg.setFill()
        progressBackgroundPath.fill()

        //progressActive Drawing
        context.saveGState()
        
        let minimalProgress = progress <= 5 ? 5 : progress > 100 ? 100 : progress //TODO: min progress ?
        let _progressCalculated = (frame.width / 100.0) * minimalProgress
        
        let progressActivePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: _progressCalculated, height: _height), cornerRadius: _height / 2)
        color_active.setFill()
        progressActivePath.fill()

        context.restoreGState()
    }
}
