//
//  SuggestionSnackbar.swift
//  entourage
//
//  Toast avec action « Annuler » : « Plus tard » retire la suggestion, il faut pouvoir revenir en arrière.
//

import UIKit

final class SuggestionSnackbar: UIView {

    private static weak var current: SuggestionSnackbar?
    private var onAction: (() -> Void)?
    private var dismissWork: DispatchWorkItem?

    static func show(message: String, actionTitle: String, duration: TimeInterval = 5, onAction: @escaping () -> Void) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        current?.removeFromSuperview()

        let bar = SuggestionSnackbar()
        bar.onAction = onAction
        bar.build(message: message, actionTitle: actionTitle)
        window.addSubview(bar)
        current = bar
        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 16),
            bar.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -16),
            bar.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -72)
        ])
        UIAccessibility.post(notification: .announcement, argument: message)

        let work = DispatchWorkItem { [weak bar] in bar?.dismiss() }
        bar.dismissWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: work)
    }

    private func build(message: String, actionTitle: String) {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(white: 0.15, alpha: 0.95)
        layer.cornerRadius = 12

        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: ApplicationTheme.getFontNunitoRegular(size: 13))
        label.adjustsFontForContentSizeCategory = true

        let button = UIButton(type: .system)
        button.setTitle(actionTitle, for: .normal)
        button.setTitleColor(.appOrange, for: .normal)
        button.titleLabel?.font = ApplicationTheme.getFontNunitoBold(size: 14)
        button.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.accessibilityIdentifier = "suggestion_undo_button"

        let stack = UIStackView(arrangedSubviews: [label, button])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }

    @objc private func actionTapped() {
        dismissWork?.cancel()
        let action = onAction
        dismiss()
        action?()
    }

    private func dismiss() {
        UIView.animate(withDuration: 0.2, animations: { self.alpha = 0 }, completion: { _ in self.removeFromSuperview() })
    }
}
