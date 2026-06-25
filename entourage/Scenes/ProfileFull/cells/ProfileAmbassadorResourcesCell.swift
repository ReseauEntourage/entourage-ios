//
//  ProfileAmbassadorResourcesCell.swift
//  entourage
//

import UIKit

protocol ProfileAmbassadorResourcesCellDelegate: AnyObject {
    func onToolkitTapped()
    func onWhatsappTapped()
    func onCharterTapped()
}

class ProfileAmbassadorResourcesCell: UITableViewCell {

    class var identifier: String { return String(describing: self) }

    weak var delegate: ProfileAmbassadorResourcesCellDelegate?

    private let stackView = UIStackView()
    private let toolkitCard = UIView()
    private let whatsappCard = UIView()
    private let charterCard = UIView()

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
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        let toolkitLabel = makeLabel("profile_ambassador_tool_toolkit".localized)
        let whatsappLabel = makeLabel("profile_ambassador_tool_whatsapp".localized)
        let charterLabel = makeLabel("profile_ambassador_tool_charter".localized)

        let toolkitIcon = makeIcon(systemName: "folder.fill")
        let whatsappIcon = makeIcon(systemName: "message.fill")
        let charterIcon = makeIcon(systemName: "doc.text.fill")

        configure(card: toolkitCard, icon: toolkitIcon, label: toolkitLabel)
        configure(card: whatsappCard, icon: whatsappIcon, label: whatsappLabel)
        configure(card: charterCard, icon: charterIcon, label: charterLabel)

        stackView.addArrangedSubview(toolkitCard)
        stackView.addArrangedSubview(whatsappCard)
        stackView.addArrangedSubview(charterCard)

        let t1 = UITapGestureRecognizer(target: self, action: #selector(toolkitTapped))
        toolkitCard.addGestureRecognizer(t1)
        toolkitCard.isUserInteractionEnabled = true

        let t2 = UITapGestureRecognizer(target: self, action: #selector(whatsappTapped))
        whatsappCard.addGestureRecognizer(t2)
        whatsappCard.isUserInteractionEnabled = true

        let t3 = UITapGestureRecognizer(target: self, action: #selector(charterTapped))
        charterCard.addGestureRecognizer(t3)
        charterCard.isUserInteractionEnabled = true
    }

    private func makeLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = ApplicationTheme.getFontNunitoBold(size: 12)
        label.textColor = UIColor(named: "black_app") ?? .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }

    private func makeIcon(systemName: String) -> UIImageView {
        let iv = UIImageView()
        iv.image = UIImage(systemName: systemName)
        iv.tintColor = .appOrange
        iv.contentMode = .scaleAspectFit
        return iv
    }

    private func configure(card: UIView, icon: UIImageView, label: UILabel) {
        card.backgroundColor = .white
        card.layer.cornerRadius = 14
        card.layer.borderColor = UIColor(named: "gris_border") != nil
            ? UIColor(named: "gris_border")!.cgColor
            : UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1).cgColor
        card.layer.borderWidth = 1
        card.layer.shadowColor = UIColor.clear.cgColor
        card.layer.shadowOpacity = 0

        let iconContainer = UIView()
        iconContainer.backgroundColor = UIColor.appBeige
        iconContainer.layer.cornerRadius = 20
        iconContainer.clipsToBounds = true
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        icon.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(icon)

        label.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iconContainer)
        card.addSubview(label)
        card.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconContainer.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            iconContainer.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),

            icon.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 20),

            label.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -6),
            label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),

            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 90)
        ])
    }

    @objc private func toolkitTapped() { delegate?.onToolkitTapped() }
    @objc private func whatsappTapped() { delegate?.onWhatsappTapped() }
    @objc private func charterTapped() { delegate?.onCharterTapped() }
}
