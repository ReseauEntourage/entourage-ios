import UIKit
import SwiftUI
import Lottie

class WelcomeJourneyCelebrationPopupViewController: UIViewController {

    // UI Elements
    private let containerView = UIView()
    private let animationView = LottieAnimationView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let ctaButton = UIButton(type: .system)

    var onDismiss: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }

    private func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        // Container
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 24
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        // Star Icon
        animationView.animation = LottieAnimation.named("congrat_short_anim 2")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(animationView)
        animationView.play()

        // Title
        titleLabel.text = "home_v2_welcome_celebration_title".localized
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        // Description
        descriptionLabel.text = "home_v2_welcome_celebration_desc".localized
        descriptionLabel.font = .systemFont(ofSize: 15, weight: .regular)
        descriptionLabel.textColor = UIColor.gray
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)

        // CTA Button
        ctaButton.setTitle("home_v2_welcome_celebration_btn".localized, for: .normal)
        ctaButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.backgroundColor = UIColor(named: "orange_app")
        ctaButton.layer.cornerRadius = 24
        ctaButton.addTarget(self, action: #selector(onCtaTap), for: .touchUpInside)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(ctaButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            animationView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 80),
            animationView.heightAnchor.constraint(equalToConstant: 80),

            titleLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            ctaButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            ctaButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            ctaButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            ctaButton.heightAnchor.constraint(equalToConstant: 50),
            ctaButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
    }

    @objc private func onCtaTap() {
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }
}
