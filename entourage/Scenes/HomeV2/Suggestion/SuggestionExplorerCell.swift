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
        // Liseré des cartes des outils solidaires de la home (HomeSolidarityToolsCell) : fond blanc, trait beige
        // de 1 pt, sans ombre. Coins de 16, ceux des lignes.
        layer.cornerRadius = 16
        layer.borderColor = UIColor.appBeige.cgColor
        layer.borderWidth = 1

        ui_icon_bg.backgroundColor = access.type.thumbBackground
        ui_icon_bg.layer.cornerRadius = 12
        ui_icon_bg.isUserInteractionEnabled = false
        ui_icon_bg.translatesAutoresizingMaskIntoConstraints = false
        // Repli d'icône par type : le moteur ne fournit pas de média.
        ui_icon.text = access.type.fallbackEmoji
        ui_icon.font = UIFont.systemFont(ofSize: 19)
        ui_icon.translatesAutoresizingMaskIntoConstraints = false
        ui_icon_bg.addSubview(ui_icon)

        // Libellé (3 lignes au plus) et contexte (2) passent sur plusieurs lignes en police agrandie, comme Android,
        // sans couper le chevron.
        ui_label.text = access.label
        ui_label.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: ApplicationTheme.getFontNunitoSemiBold(size: 14))
        ui_label.adjustsFontForContentSizeCategory = true
        ui_label.textColor = UIColor(hexString: "#1A1A1A")
        ui_label.numberOfLines = 3

        ui_context.text = access.context
        ui_context.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: ApplicationTheme.getFontNunitoRegular(size: 12))
        ui_context.adjustsFontForContentSizeCategory = true
        ui_context.textColor = UIColor(hexString: "#6D6C6C")
        ui_context.numberOfLines = 2
        ui_context.isHidden = (access.context ?? "").isEmpty

        ui_chevron.text = "›"
        ui_chevron.font = ApplicationTheme.getFontNunitoBold(size: 22)
        ui_chevron.textColor = UIColor(hexString: "#FF9739")
        ui_chevron.setContentHuggingPriority(.required, for: .horizontal)
        ui_chevron.setContentCompressionResistancePriority(.required, for: .horizontal)

        // Type de la piste (« 📅 Événement », « 🤝 Entraide »…), comme le badge de la card : sans lui, on ne voit pas
        // toujours de quoi il s'agit. Sur le fond du type, pour rester lisible sur la ligne blanche.
        let chipLabel = UILabel()
        chipLabel.text = access.badgeKey.localized
        chipLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: ApplicationTheme.getFontNunitoBold(size: 12))
        chipLabel.adjustsFontForContentSizeCategory = true
        chipLabel.textColor = access.type.badgeColor
        chipLabel.numberOfLines = 1
        chipLabel.translatesAutoresizingMaskIntoConstraints = false
        let chip = UIView()
        chip.backgroundColor = access.type.thumbBackground
        chip.layer.cornerRadius = 12
        chip.addSubview(chipLabel)
        NSLayoutConstraint.activate([
            chipLabel.topAnchor.constraint(equalTo: chip.topAnchor, constant: 4),
            chipLabel.bottomAnchor.constraint(equalTo: chip.bottomAnchor, constant: -4),
            chipLabel.leadingAnchor.constraint(equalTo: chip.leadingAnchor, constant: 11),
            chipLabel.trailingAnchor.constraint(equalTo: chip.trailingAnchor, constant: -11)
        ])
        // Le chip garde sa largeur (espace souple à droite) et se tronque s'il est trop long.
        chip.setContentHuggingPriority(.required, for: .horizontal)
        chip.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let chipRow = UIStackView(arrangedSubviews: [chip, UIView()])
        chipRow.axis = .horizontal

        let texts = UIStackView(arrangedSubviews: [chipRow, ui_label, ui_context])
        texts.axis = .vertical
        texts.spacing = 0
        texts.setCustomSpacing(4, after: chipRow)
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
        accessibilityLabel = [access.badgeKey.localized, access.label, access.context].compactMap { $0 }.joined(separator: ". ")
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
        // Titre de zone : Quicksand Bold (police des titres de l'app), taille 18 comme Android et comme les titres de section de la home.
        ui_title.font = UIFontMetrics(forTextStyle: .title3).scaledFont(for: ApplicationTheme.getFontQuickSandBold(size: 18))
        ui_title.adjustsFontForContentSizeCategory = true
        ui_title.textColor = UIColor(hexString: "#1A1A1A")
        ui_title.numberOfLines = 0
        ui_title.accessibilityTraits = .header

        ui_rows.axis = .vertical
        ui_rows.spacing = 9

        // Marges de la grille de la home iOS : lignes à 20 (comme la carte de don et les outils solidaires),
        // 12 en haut et 8 en bas, titre aligné sur les lignes.
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
            // Comme Android : deux blocs gris de 66, coins de 16, sans liseré, lus comme un seul élément.
            for index in 0..<2 {
                let placeholder = UIView()
                placeholder.backgroundColor = UIColor(hexString: "#F3F0EE")
                placeholder.layer.cornerRadius = 16
                placeholder.heightAnchor.constraint(equalToConstant: 66).isActive = true
                placeholder.isAccessibilityElement = (index == 0)
                if index == 0 { placeholder.accessibilityLabel = "suggestion_explorer_loading_a11y".localized }
                ui_rows.addArrangedSubview(placeholder)
            }
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
