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

    /// Marges à ajouter de chaque côté pour atteindre `minimumTouchSize` (0 si le bouton est déjà assez grand).
    private func hitOutsets(for size: CGSize) -> UIEdgeInsets {
        let dx = max(0, (Self.minimumTouchSize - size.width) / 2)
        let dy = max(0, (Self.minimumTouchSize - size.height) / 2)
        return UIEdgeInsets(top: dy, left: dx, bottom: dy, right: dx)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let outsets = hitOutsets(for: bounds.size)
        let area = CGRect(x: bounds.minX - outsets.left,
                          y: bounds.minY - outsets.top,
                          width: bounds.width + outsets.left + outsets.right,
                          height: bounds.height + outsets.top + outsets.bottom)
        return area.contains(point)
    }

    /// VoiceOver (focus, audit d'accessibilité) voit la même zone que le toucher.
    override var accessibilityFrame: CGRect {
        get {
            let frame = super.accessibilityFrame
            let outsets = hitOutsets(for: frame.size)
            return CGRect(x: frame.minX - outsets.left,
                          y: frame.minY - outsets.top,
                          width: frame.width + outsets.left + outsets.right,
                          height: frame.height + outsets.top + outsets.bottom)
        }
        set { super.accessibilityFrame = newValue }
    }
}
