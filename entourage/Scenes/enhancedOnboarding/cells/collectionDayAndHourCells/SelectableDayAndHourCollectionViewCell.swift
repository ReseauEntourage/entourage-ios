//
//  SelectableDayAndHourCollectionViewCell.swift
//  entourage
//
//  Created by Clement entourage on 13/11/2024.
//

import Foundation
import UIKit

class SelectableDayAndHourCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(with text: String, isSelected: Bool) {
        titleLabel.text = text
        updateAppearance(isSelected: isSelected)
    }
    
    private func updateAppearance(isSelected: Bool) {
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 15
        contentView.layer.borderColor = isSelected ? UIColor.orange.cgColor : UIColor.lightGray.cgColor
        contentView.backgroundColor = isSelected ? UIColor.orange.withAlphaComponent(0.1) : UIColor.clear
        titleLabel.textColor = isSelected ? UIColor.orange : UIColor.black
    }
}
