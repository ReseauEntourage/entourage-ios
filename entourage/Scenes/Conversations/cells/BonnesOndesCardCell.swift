//
//  BonnesOndesCardCell.swift
//  entourage
//
//  Created by Clement entourage on 15/09/2026.
//

import UIKit

/// Permanent "Rejoindre une discussion solidaire" card at the top of the Discussions list — EN-9487.
final class BonnesOndesCardCell: UITableViewCell {

    static let identifier = "BonnesOndesCardCell"

    var onDiscuterTap: (() -> Void)?

    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let ctaButton = UIButton(type: .system)

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

        cardView.backgroundColor = .appOrange
        cardView.layer.cornerRadius = 16
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        titleLabel.text = "conversation_bonnes_ondes_title".localized
        titleLabel.numberOfLines = 0
        titleLabel.font = ApplicationTheme.getFontQuickSandBold(size: 16)
        titleLabel.textColor = .white

        subtitleLabel.text = "conversation_bonnes_ondes_subtitle".localized
        subtitleLabel.numberOfLines = 0
        subtitleLabel.font = ApplicationTheme.getFontNunitoRegular(size: 13)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)

        ctaButton.setTitle("conversation_bonnes_ondes_cta".localized, for: .normal)
        ctaButton.setTitleColor(.appOrange, for: .normal)
        ctaButton.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        ctaButton.backgroundColor = .white
        ctaButton.layer.cornerRadius = 18
        ctaButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        ctaButton.addTarget(self, action: #selector(ctaTapped), for: .touchUpInside)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let mainStack = UIStackView(arrangedSubviews: [textStack, ctaButton])
        mainStack.axis = .vertical
        mainStack.alignment = .leading
        mainStack.spacing = 14
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            mainStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            mainStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }

    @objc private func ctaTapped() {
        onDiscuterTap?()
    }
}
