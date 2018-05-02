//
//  OTMenuCellView.swift
//  entourage
//
//  Created by Veronica on 02/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import Foundation

final class OTMenuCellView: UIView {
    let iconImageView = UIImageView()
    let itemLabel = UILabel()
    
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
        backgroundColor = UIColor.pfpTableBackground()
        
        iconImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(24)
            $0.width.height.equalTo(32)
        }
        iconImageView.sizeToFit()
        
        itemLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(iconImageView.snp.trailing).inset(-17)
            $0.trailing.equalToSuperview()
        }
        itemLabel.apply(style: .boldGray)
    }
}
