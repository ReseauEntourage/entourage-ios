//
//  ConversationSectionLabelCell.swift
//  entourage
//
//  Created by Clement entourage on 15/09/2026.
//

import UIKit

/// Small uppercase section label row ("VOS CONVERSATIONS") — EN-9487/EN-9490.
final class ConversationSectionLabelCell: UITableViewCell {

    static let identifier = "ConversationSectionLabelCell"

    private let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        label.font = ApplicationTheme.getFontNunitoBold(size: 11)
        label.textColor = .appGris112
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(text: String) {
        let attributed = NSAttributedString(string: text.uppercased(), attributes: [.kern: 1.0])
        label.attributedText = attributed
    }
}
