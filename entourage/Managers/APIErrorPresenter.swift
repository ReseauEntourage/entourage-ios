//
//  APIErrorPresenter.swift
//  entourage
//

import UIKit

class APIErrorPresenter: NSObject {

    static let shared = APIErrorPresenter()

    private var isPresenting = false

    private override init() {}

    func start() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAPIError(_:)),
            name: NSNotification.Name(kNotificationAPIError),
            object: nil
        )
    }

    @objc private func handleAPIError(_ notification: Notification) {
        guard !isPresenting else { return }
        let statusCode = notification.userInfo?["statusCode"] as? Int ?? 0
        DispatchQueue.main.async { [weak self] in
            self?.presentErrorSheet(statusCode: statusCode)
        }
    }

    private func presentErrorSheet(statusCode: Int) {
        guard let topVC = UIApplication.shared.topViewController(),
              !(topVC is APIErrorBottomSheetViewController) else { return }

        isPresenting = true

        let sheet = APIErrorBottomSheetViewController()
        sheet.statusCode = statusCode
        sheet.onRetry = { [weak self] in self?.isPresenting = false }
        sheet.onDismiss = { [weak self] in self?.isPresenting = false }

        if #available(iOS 15.0, *) {
            if let sheetController = sheet.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    let customDetent = UISheetPresentationController.Detent.custom { _ in 600 }
                    sheetController.detents = [customDetent]
                } else {
                    sheetController.detents = [.large()]
                }
                sheetController.prefersGrabberVisible = true
                sheetController.prefersScrollingExpandsWhenScrolledToEdge = false
            }
        }

        sheet.presentationController?.delegate = self
        topVC.present(sheet, animated: true)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension APIErrorPresenter: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        isPresenting = false
    }
}

// MARK: - UIApplication helper

private extension UIApplication {
    func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let root = base ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
        if let nav = root as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = root as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = root?.presentedViewController {
            return topViewController(base: presented)
        }
        return root
    }
}
