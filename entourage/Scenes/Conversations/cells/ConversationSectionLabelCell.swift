//
//  ConversationSectionLabelCell.swift
//  entourage
//
//  Created by Clement entourage on 15/09/2026.
//

import UIKit

/// Small section label row ("Vos conversations" / "Votre contact Entourage") — EN-9487.
final class ConversationSectionLabelCell: UITableViewCell {

    static let identifier = "ConversationSectionLabelCell"

    private let label = UILabel()
    private let filterButton = UIButton(type: .system)
    private let filterBadge = UIView()

    var onFilterTap: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        label.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)

        filterButton.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        filterButton.tintColor = .appOrange
        filterButton.isHidden = true
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        contentView.addSubview(filterButton)

        filterBadge.backgroundColor = .appAnthracite
        filterBadge.layer.cornerRadius = 4
        filterBadge.isHidden = true
        filterBadge.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(filterBadge)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            label.trailingAnchor.constraint(lessThanOrEqualTo: filterButton.leadingAnchor, constant: -8),

            filterButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            filterButton.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 26),
            filterButton.heightAnchor.constraint(equalToConstant: 26),

            filterBadge.topAnchor.constraint(equalTo: filterButton.topAnchor, constant: -2),
            filterBadge.trailingAnchor.constraint(equalTo: filterButton.trailingAnchor, constant: 2),
            filterBadge.widthAnchor.constraint(equalToConstant: 8),
            filterBadge.heightAnchor.constraint(equalToConstant: 8)
        ])
    }

    func configure(text: String) {
        label.text = text
        filterButton.isHidden = true
        filterBadge.isHidden = true
        onFilterTap = nil
    }

    /// Shows the filter icon (with active-filter badge) trailing this label — used only for "Vos conversations".
    func configureWithFilter(text: String, hasActiveFilter: Bool, onFilterTap: @escaping () -> Void) {
        label.text = text
        filterButton.isHidden = false
        filterBadge.isHidden = !hasActiveFilter
        self.onFilterTap = onFilterTap
    }

    @objc private func filterTapped() {
        onFilterTap?()
    }
}
