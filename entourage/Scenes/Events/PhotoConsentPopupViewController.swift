//
//  PhotoConsentPopupViewController.swift
//  entourage
//
//  Created by Clement entourage on 26/08/2025.
//

import UIKit
import Foundation

final class PhotoConsentPopupViewController: UIViewController {

    // MARK: - Public callbacks
    var onAccept: (() -> Void)?
    var onDecline: (() -> Void)?

    // MARK: - UI
    private let dimView = UIView()
    private let cardView = UIView()
    private let stack = UIStackView()
    private let topImageView = UIImageView(image: UIImage(named: "ic_photo_pop"))
    private let titleLabel = UILabel()
    private let separator = UIView()
    private let scrollView = UIScrollView()
    private let bodyLabel = UILabel()
    private let buttonsStack = UIStackView()
    private let declineButton = UIButton(type: .system)
    private let acceptButton = UIButton(type: .system)

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        layoutUI()
        applyTexts()
        animateIn()
    }

    // MARK: - Public presenting helper
    @discardableResult
    static func present(over presenter: UIViewController,
                        onAccept: (() -> Void)? = nil,
                        onDecline: (() -> Void)? = nil) -> PhotoConsentPopupViewController {
        let vc = PhotoConsentPopupViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.onAccept = onAccept
        vc.onDecline = onDecline
        presenter.present(vc, animated: true)
        return vc
    }

    // MARK: - UI build
    private func buildUI() {
        view.backgroundColor = .clear

        // Dim
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimView.alpha = 0
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapDim))
        dimView.addGestureRecognizer(tap)

        // Card
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 22
        cardView.layer.masksToBounds = true
        cardView.alpha = 0
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)

        // Vertical content
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(stack)

        // Top image
        topImageView.contentMode = .scaleAspectFit
        topImageView.setContentHuggingPriority(.required, for: .vertical)
        topImageView.setContentCompressionResistancePriority(.required, for: .vertical)
        stack.addArrangedSubview(topImageView)
        topImageView.heightAnchor.constraint(equalToConstant: 72).isActive = true

        // Title
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        // 👉 font helper
        titleLabel.setFontTitle(size: 15)
        titleLabel.adjustsFontForContentSizeCategory = true
        stack.addArrangedSubview(titleLabel)

        // Separator hairline (dans un container avec hauteur)
        separator.backgroundColor = UIColor(white: 0, alpha: 0.1)
        separator.translatesAutoresizingMaskIntoConstraints = false
        let sepContainer = UIView()
        sepContainer.translatesAutoresizingMaskIntoConstraints = false
        sepContainer.addSubview(separator)
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
            separator.leadingAnchor.constraint(equalTo: sepContainer.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: sepContainer.trailingAnchor),
            separator.topAnchor.constraint(equalTo: sepContainer.topAnchor),
            // étire jusqu'en bas pour être sûr que l'intrinsic ne s’effondre pas
            separator.bottomAnchor.constraint(equalTo: sepContainer.bottomAnchor),
            sepContainer.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale)
        ])
        stack.addArrangedSubview(sepContainer)

        // Scroll + body
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.setContentHuggingPriority(.defaultLow, for: .vertical)
        scrollView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        stack.addArrangedSubview(scrollView)
        // 👉 Donne une hauteur min pour éviter 0 dans le UIStackView
        let minScrollHeight = scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        minScrollHeight.priority = .required
        minScrollHeight.isActive = true

        bodyLabel.numberOfLines = 0
        // 👉 font helper
        bodyLabel.setFontBody(size: 11)
        bodyLabel.textColor = UIColor.black.withAlphaComponent(0.86)
        bodyLabel.adjustsFontForContentSizeCategory = true
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(bodyLabel)

        // Buttons
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 12
        buttonsStack.distribution = .fillEqually
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(buttonsStack)

        // Decline (outline)
        declineButton.setTitle(NSLocalizedString("photo_consent_decline", comment: ""), for: .normal)
        declineButton.titleLabel?.setFontTitle(size: 15)
        declineButton.layer.cornerRadius = 24
        declineButton.layer.borderWidth = 1
        let brand = UIColor(named: "appOrange") ?? .systemOrange
        declineButton.layer.borderColor = brand.cgColor
        declineButton.setTitleColor(brand, for: .normal)
        declineButton.backgroundColor = .clear
        declineButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        declineButton.addTarget(self, action: #selector(didTapDecline), for: .touchUpInside)

        // Accept (filled)
        acceptButton.setTitle(NSLocalizedString("photo_consent_accept", comment: ""), for: .normal)
        acceptButton.titleLabel?.setFontTitle(size: 15)
        acceptButton.layer.cornerRadius = 24
        acceptButton.backgroundColor = brand
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        acceptButton.addTarget(self, action: #selector(didTapAccept), for: .touchUpInside)

        buttonsStack.addArrangedSubview(declineButton)
        buttonsStack.addArrangedSubview(acceptButton)

        // Accessibility
        view.accessibilityViewIsModal = true
        titleLabel.accessibilityTraits = .header
    }

    private func layoutUI() {
        NSLayoutConstraint.activate([
            // dim
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // card – centered and limited in height
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.85),

            // stack inside card
            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18),

            // scroll content sizing for label
            bodyLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            bodyLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            bodyLabel.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            // important: largeur égale à la frame du scroll pour un wrapping correct
            bodyLabel.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func applyTexts() {
        titleLabel.text = NSLocalizedString("photo_consent_title", comment: "")
        bodyLabel.text = NSLocalizedString("photo_consent_body", comment: "")
    }

    // MARK: - Actions
    @objc private func didTapDecline() {
        dismiss(animated: true) { [weak self] in self?.onDecline?() }
    }

    @objc private func didTapAccept() {
        dismiss(animated: true) { [weak self] in self?.onAccept?() }
    }

    @objc private func didTapDim() {
        // Fermer si on tape le fond (désactive si tu veux forcer un choix)
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Anim
    private func animateIn() {
        cardView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        UIView.animate(withDuration: 0.22,
                       delay: 0,
                       options: [.curveEaseOut],
                       animations: {
            self.dimView.alpha = 1
            self.cardView.alpha = 1
            self.cardView.transform = .identity
        }, completion: nil)
    }
}
extension PhotoConsentPopupViewController {
    static func present(over presenter: UIViewController,
                        title: String? = nil,
                        message: String? = nil,
                        onAccept: (() -> Void)? = nil,
                        onDecline: (() -> Void)? = nil) -> PhotoConsentPopupViewController {
        let vc = PhotoConsentPopupViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.onAccept = onAccept
        vc.onDecline = onDecline

        // Personnalisation du titre et du message si fourni
        if let title = title {
            vc.titleLabel.text = title
        }
        if let message = message {
            vc.bodyLabel.text = message
        }

        presenter.present(vc, animated: true)
        return vc
    }
}
