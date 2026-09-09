//
//  ReactionBadgesView.swift
//  entourage
//
//  Rangée de pastilles (icône + compteur) affichant les réactions déjà posées
//  sur un message, en lecture seule. Portage factorisé de
//  NeighborhoodPostCell.displayReactions pour être réutilisable sur toute bulle de message.
//

import UIKit
import SDWebImage

final class ReactionBadgesView: UIView {

    var onTap: (() -> Void)?

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 4
        sv.alignment = .center
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        // Priorité haute (non required) sur le bas : évite un conflit dur avec le
        // "alignment spanner" interne du UIStackView pendant les passes de layout
        // transitoires (cellule mesurée hors hiérarchie/avant contenu chargé).
        let bottom = stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottom.priority = .defaultHigh
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            bottom,
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isHidden = true
    }

    @objc private func handleTap() {
        onTap?()
    }

    func configure(reactions: [Reaction]?, types: [ReactionType]?) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard let reactions = reactions, let types = types, !types.isEmpty else {
            isHidden = true
            return
        }

        var totalCount = 0
        for reaction in reactions where reaction.reactionsCount > 0 {
            guard let type = types.first(where: { $0.id == reaction.reactionId }) else { continue }
            stackView.addArrangedSubview(makeBadge(imageUrl: type.imageUrl))
            totalCount += reaction.reactionsCount
        }

        guard totalCount > 0 else {
            isHidden = true
            return
        }

        let countLabel = UILabel()
        countLabel.font = UIFont(name: "NunitoSans-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        countLabel.textColor = .black
        countLabel.text = "\(totalCount)"
        countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        stackView.addArrangedSubview(countLabel)

        isHidden = false
    }

    private func makeBadge(imageUrl: String?) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = 11
        container.layer.masksToBounds = true
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.appGrisReaction.cgColor
        container.backgroundColor = .white

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        container.addSubview(imageView)

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 22),
            container.heightAnchor.constraint(equalToConstant: 22),
            imageView.widthAnchor.constraint(equalToConstant: 14),
            imageView.heightAnchor.constraint(equalToConstant: 14),
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        if let urlString = imageUrl, let url = URL(string: urlString) {
            imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "ic_i_like"))
        }

        return container
    }
}
