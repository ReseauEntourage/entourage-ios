//
//  PostsSkeletonOverlayView.swift
//  entourage
//

import UIKit

/// Bloc gris avec un reflet qui balaie horizontalement en boucle — technique de shimmer standard
/// (base grise + dégradé translucide animé en transform.translation.x, clippé par le corner radius du bloc).
final class ShimmerView: UIView {

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.appGreyOff.withAlphaComponent(0.3)
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.6).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = CGRect(x: -bounds.width, y: 0, width: bounds.width * 3, height: bounds.height)
        if gradientLayer.animation(forKey: "shimmer") == nil {
            let animation = CABasicAnimation(keyPath: "transform.translation.x")
            animation.fromValue = -bounds.width
            animation.toValue = bounds.width * 2
            animation.duration = 1.3
            animation.repeatCount = .infinity
            animation.isRemovedOnCompletion = false
            gradientLayer.add(animation, forKey: "shimmer")
        }
    }
}

/// Overlay affiché à la place du fil de posts pendant qu'on pagine automatiquement
/// pour retrouver un post ciblé (deeplink/notif) — 3 cartes factices façon post, en attendant
/// de savoir où scroller. Remplace le spinner SVProgressHUD utilisé auparavant pour cette recherche.
final class PostsSkeletonOverlayView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupCards()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCards()
    }

    private func setupCards() {
        backgroundColor = UIColor(named: "white_orange_home") ?? .white

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])

        for _ in 0..<3 {
            stack.addArrangedSubview(makeCard())
        }
    }

    private func makeCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16

        let avatar = shimmerBlock(cornerRadius: 18)
        let nameLine = shimmerBlock(cornerRadius: 4)
        let bodyLine1 = shimmerBlock(cornerRadius: 4)
        let bodyLine2 = shimmerBlock(cornerRadius: 4)

        [avatar, nameLine, bodyLine1, bodyLine2].forEach { card.addSubview($0) }

        NSLayoutConstraint.activate([
            avatar.widthAnchor.constraint(equalToConstant: 36),
            avatar.heightAnchor.constraint(equalToConstant: 36),
            avatar.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            avatar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),

            nameLine.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            nameLine.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 10),
            nameLine.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -16),
            nameLine.widthAnchor.constraint(equalToConstant: 110),
            nameLine.heightAnchor.constraint(equalToConstant: 12),

            bodyLine1.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 16),
            bodyLine1.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            bodyLine1.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            bodyLine1.heightAnchor.constraint(equalToConstant: 12),

            bodyLine2.topAnchor.constraint(equalTo: bodyLine1.bottomAnchor, constant: 8),
            bodyLine2.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            bodyLine2.widthAnchor.constraint(equalTo: card.widthAnchor, multiplier: 0.6),
            bodyLine2.heightAnchor.constraint(equalToConstant: 12),
            bodyLine2.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }

    private func shimmerBlock(cornerRadius: CGFloat) -> UIView {
        let view = ShimmerView()
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
