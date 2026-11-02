//
//  SuggestionWhyViewController.swift
//  entourage
//
//  Bottom-sheet « Pourquoi cette suggestion ? » (EN-9480), ouverte par le ⓘ d'une card.
//  Les raisons viennent du payload du moteur (signaux réellement utilisés), jamais de jargon interne.
//

import UIKit

extension SuggestionReasonKind {
    var icon: String {
        switch self {
        case .proximity: return "📍"
        case .interests: return "❤️"
        case .moment: return "🗓"
        case .history: return "🕘"
        case .need: return "🔎"
        case .accessibility: return "✅"
        case .socialProof: return "👥"
        }
    }
}

final class SuggestionWhyViewController: UIViewController {

    static let maxReasons = 3

    /// 2 à 3 raisons maximum. La preuve sociale (« des voisins y participent déjà ») est écartée
    /// pour une personne isolée : elle peut l'intimider, on la réserve aux riverains.
    static func displayedReasons(for card: SuggestionCard, isolatedProfile: Bool) -> [SuggestionReason] {
        let filtered = card.reasons.filter { !(isolatedProfile && $0.kind == .socialProof) }
        return Array(filtered.prefix(maxReasons))
    }

    private let card: SuggestionCard
    private let reasons: [SuggestionReason]

    init(card: SuggestionCard, isolatedProfile: Bool) {
        self.card = card
        self.reasons = SuggestionWhyViewController.displayedReasons(for: card, isolatedProfile: isolatedProfile)
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
        icon.text = reason.kind.icon
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
