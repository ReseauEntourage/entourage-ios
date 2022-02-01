//
//  OTMenuCellView.swift
//  entourage
//
//  Created by Veronica on 02/05/2018.
//  Copyright © 2018 Entourage. All rights reserved.
//

import Foundation

final class OTMenuCellView: UIView {
    let iconImageView = UIImageView()
    let itemLabel = UILabel()
    let accImageView = UIImageView()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    // MARK: - Private Functions
    
    private func commonInit() {
        addSubview(iconImageView)
        addSubview(itemLabel)
        addSubview(accImageView)
        backgroundColor = UIColor.appTableBackground()
        
        itemLabel.numberOfLines = 2
        let marginOffset: CGFloat = 17
        let iconHeight: CGFloat = 30
        accImageView.image = UIImage.init(named: "arrowForMenu")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        accImageView.contentMode = UIView.ContentMode.scaleAspectFit
        accImageView.tintColor = UIColor.appSubtitleBlue()
        
        iconImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(marginOffset)
            $0.width.height.equalTo(iconHeight)
        }
        iconImageView.sizeToFit()
        
        itemLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(iconImageView.snp.trailing).inset(-marginOffset)
            $0.trailing.equalToSuperview().inset(iconHeight)
        }
        itemLabel.apply(style: .mediumGray)
        
        accImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(itemLabel.snp.trailing).inset(2*marginOffset)
            $0.width.height.equalTo(iconHeight/2)
            $0.trailing.width.equalTo(marginOffset)
        }
        accImageView.sizeToFit()
    }
}
