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
    let timeoutInfo = 60
    var timeOut = 60
    var countDownTimer: Timer? = nil

    weak var pageDelegate: OnboardingDelegate? {
        didSet {
            reloadSwiftUIView()
        }
    }

    // MARK: - SwiftUI hosting
    private var hostingController: UIHostingController<OnboardingSMSCodeView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupSwiftUIView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countDownTimer?.invalidate()
        countDownTimer = nil
    }

    // MARK: - Setup SwiftUI
    private func makeRootView() -> OnboardingSMSCodeView {
        let phone = tempPhone
        weak var delegate = pageDelegate

        let view = OnboardingSMSCodeView(
            phone: phone,
            onCodeFilled: { code in
                delegate?.sendCode(code: code)
            },
            onRequestNewCode: {
                delegate?.requestNewcode()
            },
            onModifyPhone: {
                delegate?.goMain()
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
