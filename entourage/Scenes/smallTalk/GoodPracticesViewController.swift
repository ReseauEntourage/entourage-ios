//
//  GoodPracticesViewController.swift
//  entourage
//
//  Created by Clement entourage on 26/05/2025.
//

import Foundation
import UIKit

class GoodPracticesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
        }
        setupScrollView()
    }

    private func setupScrollView() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.spacing = 20
        contentView.alignment = .fill
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])

        contentView.addArrangedSubview(titleLabel("Des bonnes pratiques pour des Bonnes Ondes"))
        contentView.addArrangedSubview(descriptionLabel("Les Bonnes ondes vous connectent rapidement avec une ou plusieurs personnes pour discuter et créer du lien, simplement et sans pression."))

        contentView.addArrangedSubview(sectionBox(
            title: "✅ Ce que c'est",
            items: [
                "Un échange convivial et bienveillant",
                "Une rencontre authentique entre plusieurs personnes",
                "Une occasion de briser l’isolement"
            ]
        ))

        contentView.addArrangedSubview(sectionBox(
            title: "❌ Ce que ce n'est pas",
            items: [
                "Un accompagnement social ou une aide formelle",
                "Une conversation à sens unique ou un débat",
                "Une discussion intrusive sur des sujets sensibles"
            ]
        ))

        contentView.addArrangedSubview(titleLabel("La charte éthique Entourage"))

        contentView.addArrangedSubview(ethicBox(
            icon: "🤝", title: "Bienveillance",
            text: "Nous participons à cet échange avec une intention positive et respectueuse."
        ))

        contentView.addArrangedSubview(ethicBox(
            icon: "🗣️", title: "Consentement",
            text: "Nous respectons les limites et les souhaits de notre interlocuteur."
        ))

        contentView.addArrangedSubview(ethicBox(
            icon: "🔒", title: "Confidentialité",
            text: "Nous ne partageons pas d’informations personnelles (nom, adresse, numéro de téléphone...)."
        ))

        contentView.addArrangedSubview(ethicBox(
            icon: "🌍", title: "Ouverture et non discrimination",
            text: "Nous accueillons toutes les personnes sans distinction de genre, d'origine, de croyance ou de parcours de vie."
        ))

        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Fermer", for: .normal)
        closeButton.backgroundColor = UIColor.systemOrange
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 8
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        contentView.addArrangedSubview(closeButton)
    }

    private func titleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }

    private func descriptionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }

    private func sectionBox(title: String, items: [String]) -> UIView {
        let box = UIStackView()
        box.axis = .vertical
        box.spacing = 10
        box.alignment = .leading
        box.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        box.isLayoutMarginsRelativeArrangement = true
        box.backgroundColor = UIColor.appGrey151
        box.layer.cornerRadius = 12

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        box.addArrangedSubview(titleLabel)

        for item in items {
            let itemLabel = UILabel()
            itemLabel.text = item
            itemLabel.font = UIFont.systemFont(ofSize: 15)
            itemLabel.numberOfLines = 0
            box.addArrangedSubview(itemLabel)
        }

        return box
    }

    private func ethicBox(icon: String, title: String, text: String) -> UIView {
        let box = UIStackView()
        box.axis = .vertical
        box.spacing = 5
        box.alignment = .leading
        box.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        box.isLayoutMarginsRelativeArrangement = true
        box.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
        box.layer.cornerRadius = 12

        let titleLabel = UILabel()
        titleLabel.text = "\(icon) \(title)"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        box.addArrangedSubview(titleLabel)

        let bodyLabel = UILabel()
        bodyLabel.text = text
        bodyLabel.font = UIFont.systemFont(ofSize: 15)
        bodyLabel.numberOfLines = 0
        box.addArrangedSubview(bodyLabel)

        return box
    }

    @objc private func closeTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
