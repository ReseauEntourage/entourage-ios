//
//  SuggestionCardView.swift
//  entourage
//
//  Card « Votre prochain pas » : un conteneur polymorphe (EN-9483).
//  Anatomie commune : badge de type · bouton ⓘ · média optionnel · titre ·
//  1 à 3 lignes de méta optionnelles · action principale · action secondaire.
//

import UIKit

extension SuggestionType {
    var badgeColor: UIColor {
        switch self {
        case .entraide: return UIColor(hexString: "#D53F00")
        case .contenu: return UIColor(hexString: "#2F6DB5")
        case .evenement: return UIColor(hexString: "#FF9739")
        case .groupe: return UIColor(hexString: "#1E7F51")
        case .connexion: return UIColor(hexString: "#47A8B9")
        case .lieu: return UIColor(hexString: "#B84D0E")
        }
    }

    var thumbBackground: UIColor {
        switch self {
        case .entraide: return UIColor(hexString: "#FEEAE3")
        case .contenu, .lieu: return UIColor(hexString: "#EAF2FB")
        case .evenement: return UIColor(hexString: "#FDDCD0")
        case .groupe: return UIColor(hexString: "#DEF1E8")
        case .connexion: return UIColor(hexString: "#ECF8FB")
        }
    }

    /// Repli quand le moteur ne fournit pas de média (photo / avatar absent).
    var fallbackEmoji: String {
        switch self {
        case .entraide: return "🤝"
        case .contenu: return "📘"
        case .evenement: return "📅"
        case .groupe: return "👥"
        case .connexion: return "👋"
        case .lieu: return "📍"
        }
    }

    var badgeKey: String { "suggestion_badge_\(rawValue)" }
}

extension SuggestionCTA {
    var titleKey: String {
        switch self {
        case .answer: return "suggestion_cta_answer"
        case .read: return "suggestion_cta_read"
        case .participate: return "suggestion_cta_participate"
        case .register: return "suggestion_cta_register"
        case .join: return "suggestion_cta_join"
        case .sayHello: return "suggestion_cta_say_hello"
        case .seePlace: return "suggestion_cta_see_place"
        }
    }
}

final class SuggestionCardView: UIView {

    var onInfoTapped: (() -> Void)?
    var onPrimaryTapped: (() -> Void)?
    var onLaterTapped: (() -> Void)?
    /// Tap sur le corps de la card : ouvre le détail, comme les lignes de l'Explorer.
    var onBodyTapped: (() -> Void)?

    private let ui_badge_stack = UIStackView()
    private let ui_info_button = UIButton(type: .custom)
    private let ui_media = UIView()
    private let ui_media_label = UILabel()
    private let ui_author = UILabel()
    private let ui_title = UILabel()
    private let ui_body = UILabel()
    private let ui_metas_stack = UIStackView()
    private let ui_primary = UIButton(type: .custom)
    private let ui_later = UIButton(type: .custom)
    private let ui_content = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: Setup

    private func scaled(_ font: UIFont, style: UIFont.TextStyle) -> UIFont {
        return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
    }

    private func setupUI() {
        backgroundColor = UIColor(hexString: "#FEEAE3")
        layer.cornerRadius = 16

        ui_badge_stack.axis = .horizontal
        ui_badge_stack.spacing = 6
        ui_badge_stack.alignment = .center

        ui_info_button.setTitle("ⓘ", for: .normal)
        ui_info_button.setTitleColor(UIColor(hexString: "#D53F00"), for: .normal)
        ui_info_button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        ui_info_button.backgroundColor = UIColor(red: 1, green: 149 / 255, blue: 57 / 255, alpha: 0.18)
        ui_info_button.layer.cornerRadius = 15
        ui_info_button.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
        ui_info_button.isAccessibilityElement = true
        ui_info_button.accessibilityLabel = "suggestion_why_a11y".localized
        ui_info_button.accessibilityTraits = .button
        ui_info_button.accessibilityIdentifier = "suggestion_info_button"

        // Zone tactile ≥ 44 pt autour du cercle visuel de 30 pt.
        let infoHit = UIView()
        infoHit.translatesAutoresizingMaskIntoConstraints = false
        ui_info_button.translatesAutoresizingMaskIntoConstraints = false
        infoHit.addSubview(ui_info_button)
        let infoTap = UIButton(type: .custom)
        infoTap.translatesAutoresizingMaskIntoConstraints = false
        infoTap.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
        infoTap.isAccessibilityElement = false
        infoHit.addSubview(infoTap)
        NSLayoutConstraint.activate([
            infoHit.widthAnchor.constraint(equalToConstant: 44),
            infoHit.heightAnchor.constraint(equalToConstant: 44),
            ui_info_button.widthAnchor.constraint(equalToConstant: 30),
            ui_info_button.heightAnchor.constraint(equalToConstant: 30),
            ui_info_button.centerXAnchor.constraint(equalTo: infoHit.centerXAnchor),
            ui_info_button.centerYAnchor.constraint(equalTo: infoHit.centerYAnchor),
            infoTap.topAnchor.constraint(equalTo: infoHit.topAnchor),
            infoTap.bottomAnchor.constraint(equalTo: infoHit.bottomAnchor),
            infoTap.leadingAnchor.constraint(equalTo: infoHit.leadingAnchor),
            infoTap.trailingAnchor.constraint(equalTo: infoHit.trailingAnchor)
        ])

        let topRow = UIStackView(arrangedSubviews: [ui_badge_stack, UIView(), infoHit])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 8

        ui_media.layer.cornerRadius = 12
        ui_media.translatesAutoresizingMaskIntoConstraints = false
        ui_media_label.translatesAutoresizingMaskIntoConstraints = false
        ui_media_label.textAlignment = .center
        ui_media.addSubview(ui_media_label)
        NSLayoutConstraint.activate([
            ui_media.widthAnchor.constraint(equalToConstant: 52),
            ui_media.heightAnchor.constraint(equalToConstant: 52),
            ui_media_label.centerXAnchor.constraint(equalTo: ui_media.centerXAnchor),
            ui_media_label.centerYAnchor.constraint(equalTo: ui_media.centerYAnchor)
        ])

        ui_author.font = scaled(ApplicationTheme.getFontNunitoBold(size: 13), style: .footnote)
        ui_author.textColor = UIColor(hexString: "#363636")
        ui_author.adjustsFontForContentSizeCategory = true

        // Champs libres : nombre de lignes borné, texte brut, jamais reformulé.
        ui_title.font = scaled(ApplicationTheme.getFontQuickSandBold(size: 17), style: .headline)
        ui_title.textColor = UIColor(hexString: "#1A1A1A")
        ui_title.numberOfLines = 3
        ui_title.adjustsFontForContentSizeCategory = true

        ui_body.font = scaled(ApplicationTheme.getFontNunitoRegular(size: 13), style: .footnote)
        ui_body.textColor = UIColor(hexString: "#6D6C6C")
        ui_body.numberOfLines = 4
        ui_body.adjustsFontForContentSizeCategory = true

        ui_metas_stack.axis = .vertical
        ui_metas_stack.spacing = 2

        let textStack = UIStackView(arrangedSubviews: [ui_author, ui_title, ui_body, ui_metas_stack])
        textStack.axis = .vertical
        textStack.spacing = 4

        let mediaRow = UIStackView(arrangedSubviews: [ui_media, textStack])
        mediaRow.axis = .horizontal
        mediaRow.alignment = .top
        mediaRow.spacing = 12

        // Zone « contenu » : un seul élément de lecture VoiceOver (type, titre, méta).
        ui_content.addSubview(mediaRow)
        mediaRow.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mediaRow.topAnchor.constraint(equalTo: ui_content.topAnchor),
            mediaRow.bottomAnchor.constraint(equalTo: ui_content.bottomAnchor),
            mediaRow.leadingAnchor.constraint(equalTo: ui_content.leadingAnchor),
            mediaRow.trailingAnchor.constraint(equalTo: ui_content.trailingAnchor)
        ])
        ui_content.isAccessibilityElement = true
        ui_content.accessibilityTraits = .button
        ui_content.accessibilityHint = "suggestion_body_a11y_hint".localized
        ui_content.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTapped)))

        ui_primary.backgroundColor = .appOrange
        ui_primary.setTitleColor(.white, for: .normal)
        ui_primary.titleLabel?.font = scaled(ApplicationTheme.getFontQuickSandBold(size: 14), style: .callout)
        ui_primary.titleLabel?.adjustsFontForContentSizeCategory = true
        ui_primary.titleLabel?.numberOfLines = 2
        ui_primary.titleLabel?.textAlignment = .center
        ui_primary.layer.cornerRadius = 22
        ui_primary.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        ui_primary.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        ui_primary.accessibilityIdentifier = "suggestion_primary_button"

        ui_later.setTitle("suggestion_later".localized, for: .normal)
        ui_later.setTitleColor(UIColor(hexString: "#363636"), for: .normal)
        ui_later.titleLabel?.font = scaled(ApplicationTheme.getFontNunitoSemiBold(size: 13), style: .footnote)
        ui_later.titleLabel?.adjustsFontForContentSizeCategory = true
        ui_later.layer.cornerRadius = 22
        ui_later.layer.borderWidth = 1.5
        ui_later.layer.borderColor = UIColor(hexString: "#D9D9D9").cgColor
        ui_later.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        ui_later.setContentHuggingPriority(.required, for: .horizontal)
        ui_later.addTarget(self, action: #selector(laterTapped), for: .touchUpInside)
        ui_later.accessibilityIdentifier = "suggestion_later_button"

        let actions = UIStackView(arrangedSubviews: [ui_primary, ui_later])
        actions.axis = .horizontal
        actions.spacing = 10
        actions.alignment = .fill
        actions.distribution = .fill
        ui_primary.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let root = UIStackView(arrangedSubviews: [topRow, ui_content, actions])
        root.axis = .vertical
        root.spacing = 12
        root.translatesAutoresizingMaskIntoConstraints = false
        addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            root.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            root.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            root.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            ui_primary.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            ui_later.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])

        // Ordre de lecture logique : type + titre + méta, ⓘ, action principale, action secondaire.
        isAccessibilityElement = false
        accessibilityElements = [ui_content, ui_info_button, ui_primary, ui_later]
    }

    // MARK: Configure

    func configure(card: SuggestionCard) {
        // Badge de type + chip optionnel.
        ui_badge_stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        ui_badge_stack.addArrangedSubview(makeBadge(text: card.type.badgeKey.localized, color: card.type.badgeColor, filled: true))
        var chips = [String]()
        if card.isRemote { chips.append("suggestion_chip_remote".localized) }
        if let chip = card.chip, !chip.isEmpty { chips.append(chip) }
        for chip in chips {
            ui_badge_stack.addArrangedSubview(makeBadge(text: chip, color: UIColor(hexString: "#6D6C6C"), filled: false))
        }

        // Média : avatar (initiales) pour une personne, sinon vignette emoji, repli par type.
        if let author = card.authorName, (card.type == .entraide || card.type == .connexion), card.mediaEmoji == nil {
            ui_media.layer.cornerRadius = 26
            ui_media.backgroundColor = card.type.thumbBackground
            ui_media_label.font = ApplicationTheme.getFontQuickSandBold(size: 16)
            ui_media_label.textColor = card.type.badgeColor
            ui_media_label.text = initials(of: author)
        } else {
            ui_media.layer.cornerRadius = 12
            ui_media.backgroundColor = card.type.thumbBackground
            ui_media_label.font = UIFont.systemFont(ofSize: 24)
            ui_media_label.text = card.mediaEmoji ?? card.type.fallbackEmoji
        }

        ui_author.text = card.authorName
        ui_author.isHidden = (card.authorName == nil) || card.type == .connexion
        ui_title.text = card.title
        ui_body.text = card.body
        ui_body.isHidden = (card.body ?? "").isEmpty

        // Méta : chaque ligne est optionnelle (pas de distance figée).
        ui_metas_stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for meta in card.metas {
            let label = UILabel()
            label.font = scaled(ApplicationTheme.getFontNunitoRegular(size: 13), style: .footnote)
            label.textColor = UIColor(hexString: "#6D6C6C")
            label.numberOfLines = 3
            label.adjustsFontForContentSizeCategory = true
            label.text = [meta.icon, meta.text].compactMap { $0 }.joined(separator: " ")
            ui_metas_stack.addArrangedSubview(label)
        }
        ui_metas_stack.isHidden = card.metas.isEmpty

        ui_primary.setTitle(card.cta.titleKey.localized, for: .normal)

        ui_content.accessibilityLabel = accessibilityText(for: card)
    }

    private func accessibilityText(for card: SuggestionCard) -> String {
        var parts = [card.type.badgeKey.localized, card.title]
        if let body = card.body, !body.isEmpty { parts.append(body) }
        parts.append(contentsOf: card.metas.map { $0.text })
        return parts.joined(separator: ". ")
    }

    private func makeBadge(text: String, color: UIColor, filled: Bool) -> UIView {
        let label = UILabel()
        label.font = scaled(ApplicationTheme.getFontNunitoBold(size: 11), style: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = color
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.backgroundColor = filled ? .white : UIColor(white: 1, alpha: 0.6)
        container.layer.cornerRadius = 12
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 11),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -11)
        ])
        return container
    }

    private func initials(of name: String) -> String {
        let letters = name.split(separator: " ").prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }

    // MARK: Actions

    @objc private func infoTapped() { onInfoTapped?() }
    @objc private func primaryTapped() { onPrimaryTapped?() }
    @objc private func laterTapped() { onLaterTapped?() }
    @objc private func bodyTapped() { onBodyTapped?() }
}
