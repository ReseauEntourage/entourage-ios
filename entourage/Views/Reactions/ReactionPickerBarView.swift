//
//  ReactionPickerBarView.swift
//  entourage
//
//  Barre inline de sélection de réaction (jusqu'à 5 emojis), affichée directement
//  sous une bulle de message reçue lors d'un appui long (jamais sur ses propres messages).
//  Contrairement à NeighborhoodPostCell.ReactionsPopupView, ce composant n'est pas
//  positionné en absolu par-dessus la fenêtre : il s'insère dans le flux (UIStackView)
//  de la cellule, comme le veut la référence Android.
//

import UIKit
import SDWebImage

final class ReactionPickerBarView: UIView {

    private var onPick: ((ReactionType) -> Void)?
    private var configuredTypes: [ReactionType] = []

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.distribution = .equalSpacing
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
        backgroundColor = .white
        layer.cornerRadius = 22
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.appGrisReaction.cgColor

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }

    /// Reconstruit la barre. `selectedId` (la réaction courante de l'utilisateur, 0/nil si aucune)
    /// est mis en évidence — le retaper la retire (toggle), géré par l'appelant dans `onPick`.
    func configure(types: [ReactionType], selectedId: Int?, onPick: @escaping (ReactionType) -> Void) {
        self.onPick = onPick
        self.configuredTypes = Array(types.prefix(5))
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for type in configuredTypes {
            let isSelected = (selectedId ?? 0) != 0 && type.id == selectedId

            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.layer.cornerRadius = 16
            container.layer.masksToBounds = true
            container.backgroundColor = isSelected ? UIColor.appGrisReaction.withAlphaComponent(0.5) : .clear

            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFill
            imageView.isUserInteractionEnabled = true
            imageView.tag = type.id
            container.addSubview(imageView)

            NSLayoutConstraint.activate([
                container.widthAnchor.constraint(equalToConstant: 32),
                container.heightAnchor.constraint(equalToConstant: 32),
                imageView.widthAnchor.constraint(equalToConstant: 24),
                imageView.heightAnchor.constraint(equalToConstant: 24),
                imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])

            if let urlString = type.imageUrl, let url = URL(string: urlString) {
                imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "ic_i_like"))
            }

            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            imageView.addGestureRecognizer(tap)

            stackView.addArrangedSubview(container)
        }
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let imageView = gesture.view as? UIImageView,
              let type = configuredTypes.first(where: { $0.id == imageView.tag }) else { return }

        UIView.animate(withDuration: 0.15, animations: {
            imageView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15) {
                imageView.transform = .identity
            }
        })

        onPick?(type)
    }
}
