//
//  BonnesOndesCardCell.swift
//  entourage
//
//  Created by Clement entourage on 15/09/2026.
//

import UIKit
import SwiftUI

/// Permanent "Rejoindre une discussion solidaire" card at the top of the Discussions list — EN-9487.
final class BonnesOndesCardCell: UITableViewCell {

    static let identifier = "BonnesOndesCardCell"

    var onDiscuterTap: (() -> Void)? {
        didSet { refreshRootView() }
    }

    private var hostingController: UIHostingController<BonnesOndesCardView>?

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

        let host = UIHostingController(rootView: BonnesOndesCardView(onDiscuterTap: { }))
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.backgroundColor = .clear
        contentView.addSubview(host.view)

        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            host.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            host.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            host.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        hostingController = host
    }

    private func refreshRootView() {
        hostingController?.rootView = BonnesOndesCardView(onDiscuterTap: { [weak self] in
            self?.onDiscuterTap?()
        })
    }
}
