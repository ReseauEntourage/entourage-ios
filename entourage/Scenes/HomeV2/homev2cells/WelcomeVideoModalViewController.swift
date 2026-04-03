import UIKit
import WebKit

class WelcomeVideoModalViewController: UIViewController {

    // UI Elements
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let webViewContainer = UIView()
    private var webView: WKWebView?
    private let continueButton = UIButton(type: .system)
    private let closeImageView = UIImageView()
    private let playOverlayView = UIView()
    private let playIconImageView = UIImageView()

    var onComplete: (() -> Void)?
    var onDismissOnly: (() -> Void)? // Triggered when modal is dismissed, useful to refresh home
    private var countdownTimer: Timer?
    private var secondsRemaining = 5
    private var originalButtonText = "home_v2_welcome_video_modal_btn".localized

    // Data from Backend
    private var welcomeVideoUrl: String?
    private var isVideoStarted = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        countdownTimer?.invalidate()
        webView?.stopLoading()
        webView = nil
        onDismissOnly?()
    }

    private func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        // Container
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 24
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        // Close Icon
        closeImageView.image = UIImage(named: "icon_cross")?.withRenderingMode(.alwaysTemplate)
        if closeImageView.image == nil {
            closeImageView.image = UIImage(systemName: "xmark") // Fallback
        }
        closeImageView.tintColor = .gray
        closeImageView.isUserInteractionEnabled = true
        closeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClose)))
        closeImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(closeImageView)

        // Title
        titleLabel.text = "home_v2_welcome_video_modal_title".localized
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = UIColor.black
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        // Video Placeholder / WebView
        webViewContainer.backgroundColor = UIColor.black
        webViewContainer.layer.cornerRadius = 16
        webViewContainer.clipsToBounds = true
        webViewContainer.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(webViewContainer)

        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.translatesAutoresizingMaskIntoConstraints = false
        wv.backgroundColor = .black
        webViewContainer.addSubview(wv)
        self.webView = wv

        // Play Overlay
        playOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        playOverlayView.translatesAutoresizingMaskIntoConstraints = false
        webViewContainer.addSubview(playOverlayView)

        playIconImageView.image = UIImage(systemName: "play.circle.fill")
        playIconImageView.tintColor = .white
        playIconImageView.contentMode = .scaleAspectFit
        playIconImageView.translatesAutoresizingMaskIntoConstraints = false
        playOverlayView.addSubview(playIconImageView)

        let playTap = UITapGestureRecognizer(target: self, action: #selector(onPlayTapped))
        playOverlayView.addGestureRecognizer(playTap)
        playOverlayView.isUserInteractionEnabled = true

        // Description
        descriptionLabel.text = "home_v2_welcome_video_modal_desc".localized
        descriptionLabel.font = .systemFont(ofSize: 15, weight: .regular)
        descriptionLabel.textColor = UIColor.gray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)

        // Continue Button
        continueButton.setTitle("\(originalButtonText) (\(secondsRemaining))", for: .normal)
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

        NSLayoutConstraint.activate([
            wv.topAnchor.constraint(equalTo: webViewContainer.topAnchor),
            wv.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor),
            wv.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor),
            wv.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor),

            playOverlayView.topAnchor.constraint(equalTo: webViewContainer.topAnchor),
            playOverlayView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor),
            playOverlayView.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor),
            playOverlayView.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor),

            playIconImageView.centerXAnchor.constraint(equalTo: playOverlayView.centerXAnchor),
            playIconImageView.centerYAnchor.constraint(equalTo: playOverlayView.centerYAnchor),
            playIconImageView.widthAnchor.constraint(equalToConstant: 64),
            playIconImageView.heightAnchor.constraint(equalToConstant: 64)
        ])
    }

    @objc private func onPlayTapped() {
        guard !isVideoStarted else { return }
        isVideoStarted = true
        playOverlayView.isHidden = true
        fetchVideoResource()
        startCountdown()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            containerView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            closeImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            closeImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            closeImageView.widthAnchor.constraint(equalToConstant: 24),
            closeImageView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: closeImageView.leadingAnchor, constant: -8),

            webViewContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            webViewContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            webViewContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            // Height is flexible but we want to make sure it expands as much as possible while maintaining the container's bounds.
            // Using a low priority constraint for a preferred ratio so it doesn't collapse entirely if not needed,
            // but it will shrink when the screen is too small.

            descriptionLabel.topAnchor.constraint(equalTo: webViewContainer.bottomAnchor, constant: 24),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            continueButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            continueButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            continueButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])

        // Add a flexible ratio constraint with lower priority so the video doesn't just disappear
        // but can be crushed by the top/bottom constraints of the containerView
        let heightConstraint = webViewContainer.heightAnchor.constraint(equalTo: webViewContainer.widthAnchor, multiplier: 16.0/9.0)
        heightConstraint.priority = .defaultLow
        heightConstraint.isActive = true
    }

    private func fetchVideoResource() {
        HomeService.getWelcomeResource { [weak self] pedago, error in
            guard let self = self, let pedago = pedago else { return }
            self.welcomeVideoUrl = pedago.url
            if let url = self.welcomeVideoUrl {
                self.loadCleanVideo(url: url)
            }
        }
    }

    private func loadCleanVideo(url: String) {
        guard let webView = self.webView else { return }
        let cleanUrl = url.contains("?") ? "\(url)&rel=0" : "\(url)?rel=0"
        let customHtml = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
                <style>
                    body, html { margin: 0; padding: 0; width: 100%; height: 100%; background-color: #000000; overflow: hidden; }
                    iframe { width: 100%; height: 100%; border: none; }
                </style>
            </head>
            <body>
                <iframe src="\(cleanUrl)" frameborder="0" allow="autoplay; encrypted-media; picture-in-picture" allowfullscreen></iframe>
            </body>
            </html>
        """
        webView.loadHTMLString(customHtml, baseURL: URL(string: "https://www.entourage.social"))
    }

    private func startCountdown() {
        secondsRemaining = 5
        continueButton.isEnabled = false
        continueButton.backgroundColor = .gray
        UIView.performWithoutAnimation {
            self.continueButton.setTitle("\(self.originalButtonText) (\(self.secondsRemaining))", for: .normal)
            self.continueButton.layoutIfNeeded()
        }

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            self.secondsRemaining -= 1
            if self.secondsRemaining > 0 {
                UIView.performWithoutAnimation {
                    self.continueButton.setTitle("\(self.originalButtonText) (\(self.secondsRemaining))", for: .normal)
                    self.continueButton.layoutIfNeeded()
                }
            } else {
                UIView.performWithoutAnimation {
                    self.continueButton.setTitle(self.originalButtonText, for: .normal)
                    self.continueButton.layoutIfNeeded()
                }
                self.continueButton.isEnabled = true
                self.continueButton.backgroundColor = UIColor(named: "orange_app")
                timer.invalidate()
            }
        }
    }

    @objc private func onContinueTap() {
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
