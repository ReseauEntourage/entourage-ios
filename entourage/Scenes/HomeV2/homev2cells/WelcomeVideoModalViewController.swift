import UIKit
import WebKit

class WelcomeVideoModalViewController: UIViewController {

    // UI Elements
    private let containerView = UIView()
    private let dragIndicator = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let webViewContainer = UIView()
    private var webView: WKWebView?
    // 💡 CHANGEMENT : Passage en `.custom` pour retirer l'animation système (flash) du bouton
    private let continueButton = UIButton(type: .custom)
    private let closeImageView = UIImageView()

    private var containerViewBottomConstraint: NSLayoutConstraint?

    var onComplete: (() -> Void)?
    var onDismissOnly: (() -> Void)? // Triggered when modal is dismissed, useful to refresh home
    private var countdownTimer: Timer?
    private var secondsRemaining = 5
    private var originalButtonText = "home_v2_welcome_video_modal_btn".localized

    // Data from Backend
    private var welcomeVideoUrl: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        fetchVideoResource()
        startCountdown()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Setup initial position for animation
        containerViewBottomConstraint?.constant = 1000 // Push off screen
        view.backgroundColor = .clear
        view.layoutIfNeeded()

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.containerViewBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        countdownTimer?.invalidate()
        webView?.stopLoading()
        webView = nil
        onDismissOnly?()
    }

    private func setupView() {
        view.backgroundColor = .clear // Handled in animation

        // Container
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 24
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        // Drag Indicator
        dragIndicator.backgroundColor = UIColor.systemGray4
        dragIndicator.layer.cornerRadius = 2.5
        dragIndicator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dragIndicator)

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

        // Title (Taille légèrement réduite pour gagner de la place)
        titleLabel.text = "home_v2_welcome_video_modal_title".localized
        titleLabel.setFontTitle(size: 18)
        titleLabel.textColor = UIColor.black
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        // Video Placeholder / WebView
        webViewContainer.backgroundColor = UIColor.black
        webViewContainer.layer.cornerRadius = 12 // Un peu plus fin
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

        // Description (Taille légèrement réduite)
        descriptionLabel.text = "home_v2_welcome_video_modal_desc".localized
        descriptionLabel.setFontBody(size: 15)
        descriptionLabel.textColor = UIColor.black
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)

        // Continue Button
        continueButton.setTitle("\(originalButtonText) (\(secondsRemaining))", for: .normal)
        continueButton.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 15)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.setTitleColor(.white.withAlphaComponent(0.5), for: .disabled) // Texte un peu transparent quand désactivé
        continueButton.backgroundColor = UIColor.systemGray4 // Gris plus doux pour l'état désactivé
        continueButton.layer.cornerRadius = 23 // Adapté à la nouvelle hauteur (46/2)
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
            wv.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor)
        ])
    }

    private func setupConstraints() {
        let bottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        self.containerViewBottomConstraint = bottomConstraint

        NSLayoutConstraint.activate([
            bottomConstraint,
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            dragIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            dragIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            dragIndicator.widthAnchor.constraint(equalToConstant: 40),
            dragIndicator.heightAnchor.constraint(equalToConstant: 5),

            closeImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            closeImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            closeImageView.widthAnchor.constraint(equalToConstant: 24),
            closeImageView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.topAnchor.constraint(equalTo: dragIndicator.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: closeImageView.leadingAnchor, constant: -8),

            // 💡 CHANGEMENT : On aligne la largeur sur le reste (marges de 20)
            // et on bloque la hauteur (ex: 320) pour qu'elle ne casse pas l'écran.
            webViewContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            webViewContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            webViewContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            webViewContainer.heightAnchor.constraint(equalToConstant: 320),

            descriptionLabel.topAnchor.constraint(equalTo: webViewContainer.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            continueButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            continueButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 46),
            continueButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
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
        continueButton.backgroundColor = UIColor.systemGray4 // Matcher avec le setup initial
        continueButton.setTitle("\(originalButtonText) (\(secondsRemaining))", for: .normal)

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            self.secondsRemaining -= 1
            
            // 💡 CHANGEMENT : On bloque les animations d'UIKit pour mettre à jour le bouton de manière fluide
            UIView.performWithoutAnimation {
                if self.secondsRemaining > 0 {
                    self.continueButton.setTitle("\(self.originalButtonText) (\(self.secondsRemaining))", for: .normal)
                } else {
                    self.continueButton.setTitle(self.originalButtonText, for: .normal)
                    self.continueButton.isEnabled = true
                    self.continueButton.backgroundColor = UIColor(named: "orange_app")
                    timer.invalidate()
                }
                self.continueButton.layoutIfNeeded()
            }
        }
    }

    @objc private func onContinueTap() {
        UserDefaults.standard.set(true, forKey: "hasWatchedWelcomeVideo")
        UserDefaults.standard.synchronize()

        animateDismiss { [weak self] in
            self?.dismiss(animated: false) {
                self?.onComplete?()
            }
        }
    }

    @objc private func onClose() {
        animateDismiss { [weak self] in
            self?.dismiss(animated: false, completion: nil)
        }
    }

    private func animateDismiss(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.backgroundColor = .clear
            self.containerViewBottomConstraint?.constant = self.containerView.frame.height
            self.view.layoutIfNeeded()
        }) { _ in
            completion()
        }
    }
}
