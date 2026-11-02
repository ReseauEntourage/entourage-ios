//
//  SuggestionExplorerCell.swift
//  entourage
//
//  Zone « Pour vous aujourd'hui » de la home (EN-9493) : 2 à 4 accès personnalisés
//  fournis par le moteur (explorer[]), chaque ligne entièrement cliquable.
//  Zone entière (titre compris) absente quand il n'y a aucun accès.
//

import UIKit

final class ExplorerRowView: UIControl {

    private let ui_icon_bg = UIView()
    private let ui_icon = UILabel()
    private let ui_label = UILabel()
    private let ui_context = UILabel()
    private let ui_chevron = UILabel()

    init(access: ExplorerAccess) {
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = 14
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 2)

        ui_icon_bg.backgroundColor = access.type.thumbBackground
        ui_icon_bg.layer.cornerRadius = 12
        ui_icon_bg.isUserInteractionEnabled = false
        ui_icon_bg.translatesAutoresizingMaskIntoConstraints = false
        // Repli d'icône par type : le moteur ne fournit pas de média.
        ui_icon.text = access.type.fallbackEmoji
        ui_icon.font = UIFont.systemFont(ofSize: 19)
        ui_icon.translatesAutoresizingMaskIntoConstraints = false
        ui_icon_bg.addSubview(ui_icon)

        // Libellé et contexte passent sur plusieurs lignes en police agrandie, sans couper le chevron.
        ui_label.text = access.label
        ui_label.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: ApplicationTheme.getFontNunitoBold(size: 14))
        ui_label.adjustsFontForContentSizeCategory = true
        ui_label.textColor = UIColor(hexString: "#1A1A1A")
        ui_label.numberOfLines = 0

        ui_context.text = access.context
        ui_context.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: ApplicationTheme.getFontNunitoRegular(size: 12))
        ui_context.adjustsFontForContentSizeCategory = true
        ui_context.textColor = UIColor(hexString: "#6D6C6C")
        ui_context.numberOfLines = 0
        ui_context.isHidden = (access.context ?? "").isEmpty

        ui_chevron.text = "›"
        ui_chevron.font = UIFont.boldSystemFont(ofSize: 20)
        ui_chevron.textColor = UIColor(hexString: "#FF9739")
        ui_chevron.setContentHuggingPriority(.required, for: .horizontal)
        ui_chevron.setContentCompressionResistancePriority(.required, for: .horizontal)

        let texts = UIStackView(arrangedSubviews: [ui_label, ui_context])
        texts.axis = .vertical
        texts.spacing = 2
        let row = UIStackView(arrangedSubviews: [ui_icon_bg, texts, ui_chevron])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.isUserInteractionEnabled = false
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)

        NSLayoutConstraint.activate([
            ui_icon_bg.widthAnchor.constraint(equalToConstant: 40),
            ui_icon_bg.heightAnchor.constraint(equalToConstant: 40),
            ui_icon.centerXAnchor.constraint(equalTo: ui_icon_bg.centerXAnchor),
            ui_icon.centerYAnchor.constraint(equalTo: ui_icon_bg.centerYAnchor),
            row.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 56)   // > 44 pt
        ])

        // Un seul élément VoiceOver : teaser, contexte, puis ce que fait le tap.
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = [access.label, access.context].compactMap { $0 }.joined(separator: ". ")
        accessibilityHint = "suggestion_explorer_a11y_hint".localized
        accessibilityIdentifier = "suggestion_explorer_\(access.id)"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.7 : 1 }
    }
}

final class SuggestionExplorerCell: UITableViewCell {

    class var identifier: String { return String(describing: self) }

    var onAccessTapped: ((ExplorerAccess) -> Void)?

    private let ui_title = UILabel()
    private let ui_rows = UIStackView()
    private var accesses = [ExplorerAccess]()
    /// Hauteur d'un squelette de 2 lignes : réservée pendant le chargement.
    private let skeletonHeight: CGFloat = 2 * 72

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.backgroundColor = UIColor(named: "white_orange_home")

        ui_title.text = "suggestion_explorer_title".localized
        ui_title.font = UIFontMetrics(forTextStyle: .title3).scaledFont(for: ApplicationTheme.getFontQuickSandBold(size: 17))
        ui_title.adjustsFontForContentSizeCategory = true
        ui_title.textColor = UIColor(hexString: "#1A1A1A")
        ui_title.numberOfLines = 0
        ui_title.accessibilityTraits = .header

        ui_rows.axis = .vertical
        ui_rows.spacing = 9

        let stack = UIStackView(arrangedSubviews: [ui_title, ui_rows])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    /// `accesses == nil` : chargement (squelette de hauteur fixe).
    func configure(accesses newAccesses: [ExplorerAccess]?) {
        ui_rows.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let newAccesses = newAccesses else {
            accesses = []
            let placeholder = UIView()
            placeholder.backgroundColor = .white
            placeholder.layer.cornerRadius = 14
            placeholder.heightAnchor.constraint(equalToConstant: skeletonHeight - 9).isActive = true
            placeholder.isAccessibilityElement = true
            placeholder.accessibilityLabel = "suggestion_explorer_loading_a11y".localized
            ui_rows.addArrangedSubview(placeholder)
            return
        }
        accesses = newAccesses
        for access in newAccesses {
            let row = ExplorerRowView(access: access)
            row.addTarget(self, action: #selector(rowTapped(_:)), for: .touchUpInside)
            row.tag = ui_rows.arrangedSubviews.count
            ui_rows.addArrangedSubview(row)
        }
    }

    @objc private func rowTapped(_ sender: UIControl) {
        guard sender.tag < accesses.count else { return }
        onAccessTapped?(accesses[sender.tag])
    }
}
