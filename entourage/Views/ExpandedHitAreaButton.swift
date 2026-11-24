//
//  ExpandedHitAreaButton.swift
//  entourage
//
//  Zone à toucher d'au moins 44 pt (norme Apple, équivalent iOS des 48 dp d'Android) sans changer
//  ni la taille visible du bouton ni ses contraintes. Posé sur les boutons de xib/storyboard
//  à dimension fixe sous 44 pt.
//

import UIKit

class ExpandedHitAreaButton: UIButton {

    /// Côté minimal de la zone à toucher, en points.
    static let minimumTouchSize: CGFloat = 44

    /// `rect` agrandi de chaque côté pour atteindre `minimumTouchSize` (inchangé s'il est déjà assez grand).
    static func expandedTouchArea(of rect: CGRect) -> CGRect {
        let dx = max(0, (minimumTouchSize - rect.width) / 2)
        let dy = max(0, (minimumTouchSize - rect.height) / 2)
        return rect.insetBy(dx: -dx, dy: -dy)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return Self.expandedTouchArea(of: bounds).contains(point)
    }

    /// VoiceOver (focus, audit d'accessibilité) voit la même zone que le toucher.
    override var accessibilityFrame: CGRect {
        get { return Self.expandedTouchArea(of: super.accessibilityFrame) }
        set { super.accessibilityFrame = newValue }
    }
}

/// Même zone à toucher pour une image cliquable (UIImageView + geste), qui n'est pas un UIButton.
class ExpandedHitAreaImageView: UIImageView {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return ExpandedHitAreaButton.expandedTouchArea(of: bounds).contains(point)
    }

    override var accessibilityFrame: CGRect {
        get { return ExpandedHitAreaButton.expandedTouchArea(of: super.accessibilityFrame) }
        set { super.accessibilityFrame = newValue }
    }
}
