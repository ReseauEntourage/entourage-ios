//
//  APIErrorBottomSheetViewController.swift
//  entourage
//

import UIKit
import Lottie

class APIErrorBottomSheetViewController: UIViewController {

    // MARK: - Properties

    var statusCode: Int = 0
    var onRetry: (() -> Void)?
    var onDismiss: (() -> Void)?

    // MARK: - UI Components

    private let animationView = LottieAnimationView(name: "error_404_animation")

    private let errorBadgeView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.appOrangeLight
        v.layer.cornerRadius = 12
        return v
    }()

    private let badgeErrorLabel: UILabel = {
        let l = UILabel()
        l.text = "ERREUR"
        l.font = UIFont(name: "NunitoSans-Bold", size: 11)
        l.textColor = UIColor.appOrangeDark
        return l
    }()

    private let badgeCodeLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "NunitoSans-Bold", size: 11)
        l.textColor = UIColor.appOrangeDark
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "Quicksand-Bold", size: 20)
        l.textColor = UIColor.appGrisSombre
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "NunitoSans-Regular", size: 14)
        l.textColor = UIColor.appGris112
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private lazy var primaryButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = UIColor.appOrange
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont(name: "NunitoSans-Bold", size: 15)
        b.layer.cornerRadius = 25
        b.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        return b
    }()

    private lazy var secondaryButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = .clear
        b.setTitleColor(UIColor.appGrisSombre, for: .normal)
        b.titleLabel?.font = UIFont(name: "NunitoSans-SemiBold", size: 15)
        b.layer.cornerRadius = 25
        b.layer.borderWidth = 1.5
        b.layer.borderColor = UIColor.appOrange.cgColor
        b.addTarget(self, action: #selector(secondaryTapped), for: .touchUpInside)
        return b
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureContent()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor.appBeigeClair

        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()

        let badgeStack = UIStackView(arrangedSubviews: [badgeErrorLabel, badgeCodeLabel])
        badgeStack.axis = .horizontal
        badgeStack.spacing = 6
        badgeStack.alignment = .center
        badgeStack.translatesAutoresizingMaskIntoConstraints = false

        errorBadgeView.addSubview(badgeStack)
        NSLayoutConstraint.activate([
            badgeStack.topAnchor.constraint(equalTo: errorBadgeView.topAnchor, constant: 6),
            badgeStack.bottomAnchor.constraint(equalTo: errorBadgeView.bottomAnchor, constant: -6),
            badgeStack.leadingAnchor.constraint(equalTo: errorBadgeView.leadingAnchor, constant: 14),
            badgeStack.trailingAnchor.constraint(equalTo: errorBadgeView.trailingAnchor, constant: -14),
        ])

        let mainStack = UIStackView(arrangedSubviews: [
            animationView,
            errorBadgeView,
            titleLabel,
            descriptionLabel,
            primaryButton,
            secondaryButton
        ])
        mainStack.axis = .vertical
        mainStack.alignment = .center
        mainStack.spacing = 16
        mainStack.setCustomSpacing(8, after: animationView)
        mainStack.setCustomSpacing(12, after: errorBadgeView)
        mainStack.setCustomSpacing(32, after: descriptionLabel)
        mainStack.setCustomSpacing(12, after: primaryButton)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStack)
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalToConstant: 260),
            animationView.heightAnchor.constraint(equalToConstant: 211),

            primaryButton.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
            primaryButton.heightAnchor.constraint(equalToConstant: 50),

            secondaryButton.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
            secondaryButton.heightAnchor.constraint(equalToConstant: 50),

            titleLabel.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
            descriptionLabel.widthAnchor.constraint(equalTo: mainStack.widthAnchor),

            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            mainStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
        ])
    }

    private func configureContent() {
        badgeCodeLabel.text = statusCode > 0 ? "\(statusCode)" : "???"
        let content = APIErrorContent.content(for: statusCode)
        titleLabel.text = content.title
        descriptionLabel.text = content.description
        primaryButton.setTitle(content.primaryTitle, for: .normal)
        secondaryButton.setTitle(content.secondaryTitle, for: .normal)
        primaryButton.isHidden = !content.showPrimary
    }

    // MARK: - Actions

    @objc private func primaryTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onRetry?()
        }
    }

    @objc private func secondaryTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }
}

// MARK: - Error Content Model

struct APIErrorContent {
    let title: String
    let description: String
    let primaryTitle: String
    let secondaryTitle: String
    let showPrimary: Bool

    static func content(for statusCode: Int) -> APIErrorContent {
        switch statusCode {
        case 400:
            return APIErrorContent(
                title: "Requête incorrecte",
                description: "Les données envoyées ne sont pas valides. Vérifiez vos informations et réessayez.",
                primaryTitle: "Réessayer",
                secondaryTitle: "Fermer",
                showPrimary: true
            )
        case 403:
            return APIErrorContent(
                title: "Accès refusé",
                description: "Vous n'avez pas les droits nécessaires pour accéder à cette ressource.",
                primaryTitle: "Réessayer",
                secondaryTitle: "Fermer",
                showPrimary: false
            )
        case 404:
            return APIErrorContent(
                title: "On s'est perdus en chemin\u{00A0}!",
                description: "Cette ressource n'existe pas ou a été déplacée. La communauté Entourage est toujours là pour vous.",
                primaryTitle: "Réessayer",
                secondaryTitle: "Retour",
                showPrimary: false
            )
        case 409:
            return APIErrorContent(
                title: "Conflit de données",
                description: "Cette action est en conflit avec l'état actuel. Actualisez et réessayez.",
                primaryTitle: "Réessayer",
                secondaryTitle: "Fermer",
                showPrimary: true
            )
        case 422:
            return APIErrorContent(
                title: "Données invalides",
                description: "Veuillez vérifier les informations saisies et réessayer.",
                primaryTitle: "Réessayer",
                secondaryTitle: "Fermer",
                showPrimary: true
            )
        case 429:
            return APIErrorContent(
                title: "Trop de requêtes",
                description: "Vous avez effectué trop d'actions en peu de temps. Patientez quelques instants avant de réessayer.",
                primaryTitle: "Réessayer",
                secondaryTitle: "Fermer",
                showPrimary: true
            )
        case 500...599:
            return APIErrorContent(
                title: "Erreur serveur",
                description: "Nos serveurs rencontrent un problème. Réessayez dans quelques instants.",
                primaryTitle: "Réessayer",
                secondaryTitle: "Fermer",
                showPrimary: true
            )
        default:
            return APIErrorContent(
                title: "Quelque chose s'est mal passé",
                description: "Une erreur inattendue s'est produite. Réessayez ou contactez notre support si le problème persiste.",
                primaryTitle: "Réessayer",
                secondaryTitle: "Fermer",
                showPrimary: true
            )
        }
    }
}
