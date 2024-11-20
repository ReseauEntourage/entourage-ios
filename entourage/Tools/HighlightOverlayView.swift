//
//  HighlightOverlayView.swift
//  entourage
//
//  Created by Clement entourage on 15/11/2024.
//

import Foundation
import UIKit

class HighlightOverlayView: UIView {

    private let targetView: UIView
    private let backgroundColorWithAlpha = UIColor.black.withAlphaComponent(0.5)

    init(targetView: UIView) {
        self.targetView = targetView
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Dessiner le fond semi-transparent
        context.setFillColor(backgroundColorWithAlpha.cgColor)
        context.fill(bounds)

        // Calculer les coordonnées et le rayon du cercle
        let targetFrame = targetView.convert(targetView.bounds, to: self)
        let center = CGPoint(x: targetFrame.midX, y: targetFrame.midY)
        let radius = max(targetFrame.width, targetFrame.height) * 0.7

        // Créer un "trou" dans le fond
        context.setBlendMode(.clear)
        context.addArc(center: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: false)
        context.fillPath()

        context.setBlendMode(.normal)
    }
}

extension HighlightOverlayView {
    func addBubble(with text: String, below targetView: UIView) {
        // Conteneur principal
        let containerView = UIView()
        containerView.backgroundColor = .clear // Transparent
        self.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        // ImageView (flèche)
        let imageView = UIImageView(image: UIImage(named: "img_arrow_tuto_bubble"))
        imageView.contentMode = .scaleAspectFit
        containerView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // Bulle blanche
        let bubbleView = UIView()
        bubbleView.backgroundColor = .white
        bubbleView.layer.cornerRadius = 8
        bubbleView.clipsToBounds = true
        containerView.addSubview(bubbleView)
        bubbleView.translatesAutoresizingMaskIntoConstraints = false

        // Labels dans la bulle
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = ApplicationTheme.getFontQuickSandBold(size: 13)

        let orangeLabel = UILabel()
        orangeLabel.text = "J’ai compris"
        orangeLabel.textColor = UIColor.orange
        orangeLabel.font = ApplicationTheme.getFontNunitoRegular(size: 11)
        orangeLabel.textAlignment = .center

        // Ajouter les labels à la bulle
        bubbleView.addSubview(label)
        bubbleView.addSubview(orangeLabel)

        // Contraintes pour le premier label
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -8)
        ])

        // Contraintes pour le deuxième label
        orangeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            orangeLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            orangeLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 8),
            orangeLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -8),
            orangeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8)
        ])

        // Contraintes pour la bulle (centrée dans le conteneur)
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10), // Descendre un peu la bulle
            bubbleView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            bubbleView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])

        // Contraintes pour l'image (en haut à droite du conteneur, légèrement décalée vers la gauche et chevauchée)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 30),
            imageView.heightAnchor.constraint(equalToConstant: 30),
            imageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: 0), // Décalée légèrement à gauche
            imageView.bottomAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8) // Distance ajustée entre l'image et la bulle
        ])

        // Contraintes pour le conteneur principal
        let targetFrame = targetView.convert(targetView.bounds, to: self)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 20), // Marges gauche
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -20), // Marges droite
            containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor), // Centré horizontalement
            containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: targetFrame.maxY + 10) // Position en dessous de la vue cible
        ])
    }
}
