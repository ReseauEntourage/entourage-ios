//
//  OnboardingPhase2ViewController.swift
//  entourage
//

import UIKit
import SwiftUI

final class OnboardingPhase2ViewController: UIViewController {

    // MARK: - Legacy properties conservées
    var tempCode: String? = nil

    var tempPhone: String = "" {
        didSet {
            reloadSwiftUIView()
        }
    }

    /// Durée avant de pouvoir redemander un code (en secondes)
    let timeoutInfo: Int = 60

    /// Compte à rebours courant
    private(set) var timeOut: Int = 60

    /// Timer iOS qui décrémente `timeOut`
    private var countDownTimer: Timer? = nil

    weak var pageDelegate: OnboardingDelegate? {
        didSet {
            reloadSwiftUIView()
        }
    }

    // MARK: - SwiftUI hosting
    private var hostingController: UIHostingController<OnboardingSMSCodeView>?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        timeOut = timeoutInfo
        setupSwiftUIView()
        startTimerIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Au cas où on revient sur l’écran
        startTimerIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelTimer()
    }

    deinit {
        cancelTimer()
    }

    // MARK: - Timer

    /// Démarre le timer si nécessaire
    private func startTimerIfNeeded() {
        // Déjà en cours
        guard countDownTimer == nil else { return }

        // Si déjà à zéro, on ne relance pas
        if timeOut <= 0 {
            timeOut = 0
            reloadSwiftUIView()
            return
        }

        // Normalisation de la valeur
        if timeOut > timeoutInfo || timeOut <= 0 {
            timeOut = timeoutInfo
        }

        reloadSwiftUIView()

        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            guard let self = self else {
                t.invalidate()
                return
            }

            self.timeOut -= 1

            if self.timeOut <= 0 {
                self.timeOut = 0
                t.invalidate()
                self.countDownTimer = nil
            }

            self.reloadSwiftUIView()
        }

        // Pour que le timer continue pendant les interactions
        RunLoop.main.add(timer, forMode: .common)
        countDownTimer = timer
    }

    /// Redémarre le timer depuis timeoutInfo
    private func restartTimer() {
        cancelTimer()
        timeOut = timeoutInfo
        startTimerIfNeeded()
    }

    /// Arrête le timer
    private func cancelTimer() {
        countDownTimer?.invalidate()
        countDownTimer = nil
    }

    // MARK: - Setup SwiftUI

    private func makeRootView() -> OnboardingSMSCodeView {
        let phone = tempPhone
        let remaining = max(timeOut, 0)
        let canRetry = (remaining == 0)

        let view = OnboardingSMSCodeView(
            phone: phone,
            timeRemaining: remaining,
            canRetry: canRetry,
            onCodeFilled: { [weak self] code in
                self?.pageDelegate?.sendCode(code: code)
            },
            onRequestNewCode: { [weak self] in
                guard let self = self else { return }

                // On ne laisse pas la vue déclencher si ce n’est pas permis
                guard self.timeOut == 0 else { return }

                self.pageDelegate?.requestNewcode()
                self.restartTimer()
            },
            onModifyPhone: { [weak self] in
                self?.pageDelegate?.goMain()
            }
        )

        return view
    }

    private func setupSwiftUIView() {
        let root = makeRootView()
        let host = UIHostingController(rootView: root)

        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host.view)

        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        host.didMove(toParent: self)
        hostingController = host
    }

    private func reloadSwiftUIView() {
        guard let host = hostingController else { return }
        host.rootView = makeRootView()
    }
}
