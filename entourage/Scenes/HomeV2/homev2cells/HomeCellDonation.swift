//
//  HomeCellDonation.swift
//  entourage
//
//  Created by Clement entourage on 30/10/2026.
//

import Foundation
import UIKit

class HomeCellDonation: UITableViewCell {

    // VAR
    class var identifier: String {
        return String(describing: self)
    }

    var onDonateTapped: (() -> Void)?

    private let ui_card = UIView()
    private let ui_icon_circle = UIView()
    private let ui_icon = UIImageView()
    private let ui_label_title = UILabel()
    private let ui_label_text = UILabel()
    private let ui_button_donate = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.backgroundColor = UIColor(named: "white_orange_home")

        ui_card.translatesAutoresizingMaskIntoConstraints = false
        ui_card.backgroundColor = .white
        ui_card.layer.cornerRadius = 16
        ui_card.layer.borderWidth = 1
        ui_card.layer.borderColor = UIColor(hexString: "#FEEAE3").cgColor
        ui_card.layer.shadowColor = UIColor.black.cgColor
        ui_card.layer.shadowOpacity = 0.08
        ui_card.layer.shadowRadius = 4
        ui_card.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.addSubview(ui_card)

        ui_icon_circle.translatesAutoresizingMaskIntoConstraints = false
        ui_icon_circle.backgroundColor = UIColor(hexString: "#FEEAE3")
        ui_icon_circle.layer.cornerRadius = 20
        ui_card.addSubview(ui_icon_circle)

        ui_icon.translatesAutoresizingMaskIntoConstraints = false
        ui_icon.image = UIImage(systemName: "heart.fill")
        ui_icon.tintColor = UIColor(hexString: "#FF9739")
        ui_icon.contentMode = .scaleAspectFit
        ui_icon_circle.addSubview(ui_icon)

        ui_label_title.translatesAutoresizingMaskIntoConstraints = false
        ui_label_title.text = "home_v2_donation_title".localized
        ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: 16)
        ui_label_title.textColor = .black
        ui_label_title.numberOfLines = 0

        ui_label_text.translatesAutoresizingMaskIntoConstraints = false
        ui_label_text.text = "home_v2_donation_text".localized
        ui_label_text.font = ApplicationTheme.getFontNunitoRegular(size: 13)
        ui_label_text.textColor = .black
        ui_label_text.numberOfLines = 0

        ui_button_donate.translatesAutoresizingMaskIntoConstraints = false
        ui_button_donate.setTitle("home_v2_donation_button".localized, for: .normal)
        ui_button_donate.setTitleColor(.white, for: .normal)
        ui_button_donate.titleLabel?.font = ApplicationTheme.getFontNunitoBold(size: 14)
        ui_button_donate.backgroundColor = .appOrange
        ui_button_donate.layer.cornerRadius = 22
        ui_button_donate.contentEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        ui_button_donate.addTarget(self, action: #selector(donateTapped), for: .touchUpInside)

        let textStack = UIStackView(arrangedSubviews: [ui_label_title, ui_label_text])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 4
        ui_card.addSubview(textStack)
        ui_card.addSubview(ui_button_donate)

        NSLayoutConstraint.activate([
            ui_card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            ui_card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            ui_card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ui_card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            ui_icon_circle.widthAnchor.constraint(equalToConstant: 40),
            ui_icon_circle.heightAnchor.constraint(equalToConstant: 40),
            ui_icon_circle.leadingAnchor.constraint(equalTo: ui_card.leadingAnchor, constant: 16),
            ui_icon_circle.topAnchor.constraint(equalTo: ui_card.topAnchor, constant: 16),

            ui_icon.centerXAnchor.constraint(equalTo: ui_icon_circle.centerXAnchor),
            ui_icon.centerYAnchor.constraint(equalTo: ui_icon_circle.centerYAnchor),
            ui_icon.widthAnchor.constraint(equalToConstant: 20),
            ui_icon.heightAnchor.constraint(equalToConstant: 20),

            textStack.topAnchor.constraint(equalTo: ui_card.topAnchor, constant: 16),
            textStack.leadingAnchor.constraint(equalTo: ui_icon_circle.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: ui_card.trailingAnchor, constant: -16),

            ui_button_donate.topAnchor.constraint(equalTo: textStack.bottomAnchor, constant: 12),
            ui_button_donate.leadingAnchor.constraint(equalTo: textStack.leadingAnchor),
            ui_button_donate.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            ui_button_donate.bottomAnchor.constraint(equalTo: ui_card.bottomAnchor, constant: -16)
        ])
    }

    @objc private func donateTapped() {
        onDonateTapped?()
    }
}
