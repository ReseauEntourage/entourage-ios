import UIKit
import SwiftUI

class WelcomeVideoModalViewController: UIViewController {

    // UI Elements
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let videoPlaceholderView = UIView()
    private let videoIconImageView = UIImageView()
    private let continueButton = UIButton(type: .system)

    var onComplete: (() -> Void)?
    private var isVideoClicked = false

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

        // Video Placeholder
        videoPlaceholderView.backgroundColor = UIColor(named: "orange_light_a50")?.withAlphaComponent(0.3)
        videoPlaceholderView.layer.cornerRadius = 16
        videoPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onVideoTap))
        videoPlaceholderView.addGestureRecognizer(tapGesture)
        containerView.addSubview(videoPlaceholderView)

        // Video Icon
        videoIconImageView.image = UIImage(systemName: "play.circle.fill")
        videoIconImageView.tintColor = UIColor(named: "orange_app")
        videoIconImageView.translatesAutoresizingMaskIntoConstraints = false
        videoPlaceholderView.addSubview(videoIconImageView)

        // Title
        titleLabel.text = "home_v2_welcome_video_modal_title".localized
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = UIColor.black
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        // Description
        descriptionLabel.text = "home_v2_welcome_video_modal_desc".localized
        descriptionLabel.font = .systemFont(ofSize: 15, weight: .regular)
        descriptionLabel.textColor = UIColor.gray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)

        // Continue Button
        continueButton.setTitle("home_v2_welcome_video_modal_btn".localized, for: .normal)
        continueButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.backgroundColor = UIColor.gray // Disabled state initially
        continueButton.layer.cornerRadius = 24
        continueButton.isEnabled = false
        continueButton.addTarget(self, action: #selector(onContinueTap), for: .touchUpInside)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(continueButton)

        // Add Close gesture to background
        let bgTap = UITapGestureRecognizer(target: self, action: #selector(onClose))
        view.addGestureRecognizer(bgTap)
        containerView.addGestureRecognizer(UITapGestureRecognizer()) // Prevent tap on modal from closing
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            videoPlaceholderView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            videoPlaceholderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            videoPlaceholderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            videoPlaceholderView.heightAnchor.constraint(equalToConstant: 180),

            videoIconImageView.centerXAnchor.constraint(equalTo: videoPlaceholderView.centerXAnchor),
            videoIconImageView.centerYAnchor.constraint(equalTo: videoPlaceholderView.centerYAnchor),
            videoIconImageView.widthAnchor.constraint(equalToConstant: 60),
            videoIconImageView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.topAnchor.constraint(equalTo: videoPlaceholderView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            continueButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            continueButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            continueButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }

    @objc private func onVideoTap() {
        if !isVideoClicked {
            isVideoClicked = true
            // Enable button
            continueButton.isEnabled = true
            continueButton.backgroundColor = UIColor(named: "orange_app")

            // "Play" visual feedback
            videoIconImageView.tintColor = UIColor.gray

            // Open video URL if needed
            let urlStr = "https://www.youtube.com/watch?v=YOUR_VIDEO_ID" // Placeholder
            if let url = URL(string: urlStr) {
                // WebLinkManager.openUrlInApp(url: url, presenterViewController: self)
                // We just mock it for now since the video is "à venir"
            }
        }
    }

    @objc private func onContinueTap() {
        // Mark as watched locally
        UserDefaults.standard.set(true, forKey: "hasWatchedWelcomeVideo")
        UserDefaults.standard.synchronize()

        dismiss(animated: true) { [weak self] in
            self?.onComplete?()
        }
    }

    @objc private func onClose() {
        dismiss(animated: true, completion: nil)
    }
}
