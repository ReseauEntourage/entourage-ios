//
//  SuggestionWhyViewController.swift
//  entourage
//
//  Bottom-sheet « Pourquoi cette suggestion ? » (EN-9480), ouverte par le ⓘ d'une card.
//  Les raisons viennent du payload du moteur (signaux réellement utilisés), jamais de jargon interne.
//

import UIKit

extension SuggestionReason {
    /// L'icône dépend du code de la raison ; un code inconnu (moteur plus récent) prend l'icône par défaut.
    var icon: String {
        switch code {
        case "near_you": return "📍"
        case "shared_interests": return "❤️"
        case "upcoming_event", "online_event": return "🗓"
        case "popular", "help_offered", "neighbor_needs_help": return "👥"
        case "answers_your_need", "poi_for_need": return "🔎"
        case "local_group", "national_group", "group_member_message": return "🏘️"
        case "content_path": return "📘"
        case "smalltalk", "papotage": return "💬"
        case "become_ambassador": return "🌟"
        default: return "✅"
        }
    }
}

final class SuggestionWhyViewController: UIViewController {

    static let maxReasons = 3

    /// Les phrases du moteur, telles quelles : il a déjà choisi la variante adaptée à la personne
    /// (variante douce comprise). L'app n'en reformule, n'en construit et n'en masque aucune.
    static func displayedReasons(for card: SuggestionCard) -> [SuggestionReason] {
        return Array(card.reasons.prefix(maxReasons))
    }

    private let card: SuggestionCard
    private let reasons: [SuggestionReason]

    init(card: SuggestionCard) {
        self.card = card
        self.reasons = SuggestionWhyViewController.displayedReasons(for: card)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *), let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.accessibilityViewIsModal = true
        buildUI()
        AnalyticsLoggerManager.logEvent(name: Suggestion_Why_View, parameters: ["type": card.type.rawValue, "id": card.id])
    }

    private func buildUI() {
        let title = UILabel()
        title.text = "suggestion_why_title_\(card.type.rawValue)".localized
        title.font = UIFontMetrics(forTextStyle: .title3).scaledFont(for: ApplicationTheme.getFontQuickSandBold(size: 20))
        title.adjustsFontForContentSizeCategory = true
        title.textColor = UIColor(hexString: "#1A1A1A")
        title.numberOfLines = 0
        title.accessibilityTraits = .header

        let reasonsStack = UIStackView(arrangedSubviews: reasons.map { makeReasonRow($0) })
        reasonsStack.axis = .vertical
        reasonsStack.spacing = 14

        let footer = UILabel()
        footer.text = "suggestion_why_footer".localized
        footer.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: ApplicationTheme.getFontNunitoRegular(size: 13))
        footer.adjustsFontForContentSizeCategory = true
        footer.textColor = UIColor(hexString: "#6D6C6C")
        footer.numberOfLines = 0

        let close = UIButton(type: .custom)
        close.setTitle("suggestion_why_close".localized, for: .normal)
        close.setTitleColor(.white, for: .normal)
        close.titleLabel?.font = UIFontMetrics(forTextStyle: .callout).scaledFont(for: ApplicationTheme.getFontQuickSandBold(size: 15))
        close.titleLabel?.adjustsFontForContentSizeCategory = true
        close.backgroundColor = .appOrange
        close.layer.cornerRadius = 24
        close.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        close.accessibilityIdentifier = "suggestion_why_close_button"
        close.heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true

        let stack = UIStackView(arrangedSubviews: [title, reasonsStack, footer, close])
        stack.axis = .vertical
        stack.spacing = 20
        stack.setCustomSpacing(16, after: reasonsStack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -48)
        ])
    }

    private func makeReasonRow(_ reason: SuggestionReason) -> UIView {
        let iconBg = UIView()
        iconBg.backgroundColor = UIColor(hexString: "#FEEAE3")
        iconBg.layer.cornerRadius = 20
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        let icon = UILabel()
        icon.text = reason.icon
        icon.font = UIFont.systemFont(ofSize: 18)
        icon.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(icon)
        NSLayoutConstraint.activate([
            iconBg.widthAnchor.constraint(equalToConstant: 40),
            iconBg.heightAnchor.constraint(equalToConstant: 40),
            icon.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor)
        ])
        iconBg.isAccessibilityElement = false

        let text = UILabel()
        text.text = reason.text
        text.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: ApplicationTheme.getFontNunitoRegular(size: 15))
        text.adjustsFontForContentSizeCategory = true
        text.textColor = UIColor(hexString: "#363636")
        text.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [iconBg, text])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        return row
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
