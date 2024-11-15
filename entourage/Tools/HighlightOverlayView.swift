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
        let bubbleView = UIView()
        bubbleView.backgroundColor = .white
        bubbleView.layer.cornerRadius = 8
        bubbleView.clipsToBounds = true

        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center

        bubbleView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -8),
            label.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8)
        ])

        self.addSubview(bubbleView)
        bubbleView.translatesAutoresizingMaskIntoConstraints = false

        // Obtenir la position cible
        let targetFrame = targetView.convert(targetView.bounds, to: self)

        // Positionner la bulle juste en dessous de la vue cible
        NSLayoutConstraint.activate([
            bubbleView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 80),
            bubbleView.topAnchor.constraint(equalTo: self.topAnchor, constant: targetFrame.maxY + 20), // Position en dessous
            bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: 200)
        ])
    }
}
