//
//  SuggestionHeroCell.swift
//  entourage
//
//  Cellule de la home qui porte la card « Votre prochain pas » (EN-9483).
//  Pendant le chargement : un squelette de hauteur proche de la card, pour que
//  l'arrivée de la suggestion ne fasse pas sauter le contenu en dessous.
//

import UIKit

final class SuggestionHeroCell: UITableViewCell {

    class var identifier: String { return String(describing: self) }

    var onInfoTapped: ((SuggestionCard) -> Void)?
    var onPrimaryTapped: ((SuggestionCard) -> Void)?
    var onLaterTapped: ((SuggestionCard) -> Void)?
    var onBodyTapped: ((SuggestionCard) -> Void)?

    private let ui_title = UILabel()
    private let card = SuggestionCardView()
    private let skeleton = UIView()
    private var currentCard: SuggestionCard?

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

        ui_title.text = "suggestion_hero_title".localized
        ui_title.font = UIFontMetrics(forTextStyle: .title3).scaledFont(for: ApplicationTheme.getFontQuickSandBold(size: 17))
        ui_title.adjustsFontForContentSizeCategory = true
        ui_title.textColor = UIColor(hexString: "#1A1A1A")
        ui_title.numberOfLines = 0
        ui_title.accessibilityTraits = .header

        card.translatesAutoresizingMaskIntoConstraints = false
        card.onInfoTapped = { [weak self] in if let c = self?.currentCard { self?.onInfoTapped?(c) } }
        card.onPrimaryTapped = { [weak self] in if let c = self?.currentCard { self?.onPrimaryTapped?(c) } }
        card.onLaterTapped = { [weak self] in if let c = self?.currentCard { self?.onLaterTapped?(c) } }
        card.onBodyTapped = { [weak self] in if let c = self?.currentCard { self?.onBodyTapped?(c) } }

        buildSkeleton()

        let stack = UIStackView(arrangedSubviews: [ui_title, card, skeleton])
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

    private func buildSkeleton() {
        skeleton.backgroundColor = UIColor(hexString: "#FEEAE3")
        skeleton.layer.cornerRadius = 16
        skeleton.translatesAutoresizingMaskIntoConstraints = false
        skeleton.heightAnchor.constraint(equalToConstant: 200).isActive = true
        skeleton.isAccessibilityElement = true
        skeleton.accessibilityLabel = "suggestion_loading_a11y".localized

        let widths: [CGFloat] = [90, 220, 160]
        let bars = widths.map { width -> UIView in
            let bar = UIView()
            bar.backgroundColor = UIColor(white: 1, alpha: 0.7)
            bar.layer.cornerRadius = 7
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.heightAnchor.constraint(equalToConstant: 14).isActive = true
            bar.widthAnchor.constraint(equalToConstant: width).isActive = true
            return bar
        }
        let barsStack = UIStackView(arrangedSubviews: bars)
        barsStack.axis = .vertical
        barsStack.alignment = .leading
        barsStack.spacing = 12
        barsStack.translatesAutoresizingMaskIntoConstraints = false
        skeleton.addSubview(barsStack)
        NSLayoutConstraint.activate([
            barsStack.topAnchor.constraint(equalTo: skeleton.topAnchor, constant: 18),
            barsStack.leadingAnchor.constraint(equalTo: skeleton.leadingAnchor, constant: 16)
        ])
    }

    /// `card == nil` : état de chargement (squelette).
    func configure(card model: SuggestionCard?) {
        currentCard = model
        if let model = model {
            card.configure(card: model)
            card.isHidden = false
            skeleton.isHidden = true
        } else {
            card.isHidden = true
            skeleton.isHidden = false
        }
    }
}
