//
//  ProfileAmbassadorModeratorCell.swift
//  entourage
//

import UIKit
import SDWebImage

protocol ProfileAmbassadorModeratorCellDelegate: AnyObject {
    func onSendMessageToReferent()
}

class ProfileAmbassadorModeratorCell: UITableViewCell {

    class var identifier: String { return String(describing: self) }

    weak var delegate: ProfileAmbassadorModeratorCellDelegate?

    private let cardView = UIView()
    private let avatarImageView = UIImageView()
    private let initialsLabel = UILabel()
    private let nameLabel = UILabel()
    private let roleLabel = UILabel()
    private let ctaButton = UIButton(type: .system)

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

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 15
        cardView.layer.borderColor = UIColor.appBeige.cgColor
        cardView.layer.borderWidth = 1
        cardView.layer.shadowColor = UIColor.clear.cgColor
        cardView.layer.shadowOpacity = 0
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        // Avatar
        avatarImageView.layer.cornerRadius = 23
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.borderColor = UIColor.appOrangeLight.cgColor
        avatarImageView.layer.borderWidth = 1
        avatarImageView.backgroundColor = UIColor.appBeige
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(avatarImageView)

        // Initials fallback inside avatar
        initialsLabel.font = UIFont(name: "Quicksand-Bold", size: 16) ?? .boldSystemFont(ofSize: 16)
        initialsLabel.textColor = .appOrange
        initialsLabel.textAlignment = .center
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.addSubview(initialsLabel)

        // Name label
        nameLabel.font = UIFont(name: "Quicksand-Bold", size: 15) ?? .boldSystemFont(ofSize: 15)
        nameLabel.textColor = UIColor(named: "black_app") ?? .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)

        // Role label
        roleLabel.text = "profile_ambassador_referent_role".localized
        roleLabel.font = UIFont(name: "NunitoSans-Regular", size: 13) ?? .systemFont(ofSize: 13)
        roleLabel.textColor = UIColor(named: "gris_fonce") ?? .gray
        roleLabel.numberOfLines = 0
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(roleLabel)

        // CTA button
        ctaButton.setTitle("profile_ambassador_referent_cta".localized, for: .normal)
        ctaButton.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 14) ?? .boldSystemFont(ofSize: 14)
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.backgroundColor = .appOrange
        ctaButton.layer.cornerRadius = 20
        ctaButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.addTarget(self, action: #selector(ctaTapped), for: .touchUpInside)
        cardView.addSubview(ctaButton)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            avatarImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            avatarImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 46),
            avatarImageView.heightAnchor.constraint(equalToConstant: 46),

            initialsLabel.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: ctaButton.leadingAnchor, constant: -8),

            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            roleLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            roleLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -16),

            ctaButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            ctaButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            ctaButton.heightAnchor.constraint(equalToConstant: 40),

            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 78)
        ])
    }

    func configure(displayName: String?, imageUrl: String?) {
        nameLabel.text = displayName ?? ""

        if let urlStr = imageUrl, let url = URL(string: urlStr) {
            initialsLabel.isHidden = true
            avatarImageView.sd_setImage(with: url, placeholderImage: nil, completed: { [weak self] image, _, _, _ in
                if image == nil {
                    self?.showInitials(from: displayName)
                }
            })
        } else {
            showInitials(from: displayName)
        }
    }

    private func showInitials(from name: String?) {
        avatarImageView.image = nil
        initialsLabel.isHidden = false
        initialsLabel.text = initials(from: name)
    }

    private func initials(from name: String?) -> String {
        guard let name = name, !name.isEmpty else { return "?" }
        let parts = name.components(separatedBy: " ").filter { !$0.isEmpty }
        if parts.count >= 2 {
            let first = parts[0].prefix(1)
            let last = parts[parts.count - 1].prefix(1)
            return "\(first)\(last)".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    @objc private func ctaTapped() {
        delegate?.onSendMessageToReferent()
    }
}
