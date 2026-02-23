import UIKit
import Lottie

class BirthdayViewController: UIViewController {

    private let backgroundCircleView = UIView()
    private let animationView = LottieAnimationView(name: "birthday_animation")
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let closeButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        // Fallback animation if birthday_animation.json is missing
        if Bundle.main.url(forResource: "birthday_animation", withExtension: "json") == nil {
            animationView.animation = LottieAnimation.named("congrats_animation")
        }

        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(named: "white_orange_home") ?? .white

        // Background Circle
        backgroundCircleView.backgroundColor = UIColor(white: 1.0, alpha: 0.5) // Slightly transparent white or custom color
        // Android used #FFF8F6 which is very light. white_orange_home might be close.
        // Let's use a specific color or just white with alpha to distinguish.
        backgroundCircleView.layer.cornerRadius = 150 // Will adjust in layout
        backgroundCircleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundCircleView)

        // Animation View
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        // Title Label
        titleLabel.text = "birthday_title".localized
        titleLabel.font = ApplicationTheme.getFontNunitoBold(size: 24) // Check font usage
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Subtitle Label
        subtitleLabel.text = "birthday_subtitle".localized
        subtitleLabel.font = ApplicationTheme.getFontNunitoRegular(size: 16)
        subtitleLabel.textColor = .black
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)

        // Close Button
        closeButton.setTitle("birthday_button".localized, for: .normal)
        closeButton.backgroundColor = UIColor.appOrange
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.titleLabel?.font = ApplicationTheme.getFontNunitoBold(size: 15)
        closeButton.layer.cornerRadius = 24
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        view.addSubview(closeButton)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Circle View
            backgroundCircleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundCircleView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            backgroundCircleView.widthAnchor.constraint(equalToConstant: 300),
            backgroundCircleView.heightAnchor.constraint(equalToConstant: 300),

            // Animation View
            animationView.centerXAnchor.constraint(equalTo: backgroundCircleView.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: backgroundCircleView.centerYAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 250),
            animationView.heightAnchor.constraint(equalToConstant: 250),

            // Title Label
            titleLabel.topAnchor.constraint(equalTo: backgroundCircleView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            // Subtitle Label
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            // Close Button
            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            closeButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundCircleView.layer.cornerRadius = backgroundCircleView.frame.width / 2
    }

    @objc private func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}
