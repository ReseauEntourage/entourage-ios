//
//  Extensions_Accessibility.swift
//  entourage
//
//  Noms vocaux (VoiceOver) : libellés localisés avec repli sur le français,
//  et clé de libellé posable depuis Interface Builder.
//

import SwiftUI
import UIKit

extension String {
    /// Libellé vocal localisé.
    ///
    /// `"clé".localized` renvoie la **clé brute** quand elle manque dans la langue choisie dans l'app
    /// (`LanguageManager`, aucun repli) : VoiceOver la lirait telle quelle. Ici, on retombe sur le français,
    /// et sur une chaîne vide (donc le comportement par défaut de VoiceOver) si la clé manque aussi en français.
    var a11y: String {
        let value = localized
        if value != self { return value }
        let fallback = String.a11yFallbackBundle?.localizedString(forKey: self, value: nil, table: nil) ?? self
        return fallback == self ? "" : fallback
    }

    private static let a11yFallbackBundle: Bundle? = {
        guard let path = Bundle.main.path(forResource: "fr", ofType: "lproj") else { return nil }
        return Bundle(path: path)
    }()
}

extension UIView {
    /// Clé du libellé vocal, posée depuis Interface Builder (attribut d'exécution `a11yKey`, type String).
    ///
    /// Résolue au chargement du xib ou du storyboard, donc dans la langue choisie dans l'app
    /// (le changement de langue recharge l'écran racine, voir `LanguageManager.setLocale`).
    /// Un libellé saisi directement dans l'inspecteur Interface Builder ne suivrait pas ce choix.
    @objc var a11yKey: String? {
        get { return nil }
        set {
            guard let key = newValue, !key.isEmpty else { return }
            isAccessibilityElement = true
            accessibilityLabel = key.a11y
        }
    }
}

// MARK: - Zone à toucher (SwiftUI) -

private struct TouchTargetSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}

private struct MinimumTouchTarget: ViewModifier {
    @State private var size: CGSize = .zero

    func body(content: Content) -> some View {
        let dx = max(0, (ExpandedHitAreaButton.minimumTouchSize - size.width) / 2)
        let dy = max(0, (ExpandedHitAreaButton.minimumTouchSize - size.height) / 2)
        return content
            .background(GeometryReader { Color.clear.preference(key: TouchTargetSizeKey.self, value: $0.size) })
            .onPreferenceChange(TouchTargetSizeKey.self) { size = $0 }
            .padding(.horizontal, dx).padding(.vertical, dy)
            .contentShape(Rectangle())
            .padding(.horizontal, -dx).padding(.vertical, -dy)
    }
}

extension View {
    /// Zone à toucher d'au moins 44 pt, sans changer la taille visible ni la mise en page
    /// (équivalent SwiftUI de `ExpandedHitAreaButton`).
    func minimumTouchTarget() -> some View {
        modifier(MinimumTouchTarget())
    }
}
