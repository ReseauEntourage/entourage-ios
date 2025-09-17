//
//  SmallTalkInterestCell.swift
//  entourage
//
//  Created by Clement entourage on 20/05/2025.
//

import Foundation
import UIKit

class SmallTalkInterestCell: UICollectionViewCell {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func configure(with text: String) {
        label.text = text
    }

    private func setup() {
        backgroundColor = .orange
        layer.cornerRadius = 15
        clipsToBounds = true

        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }
}
