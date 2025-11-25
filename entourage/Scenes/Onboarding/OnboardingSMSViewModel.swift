//
//  OnboardingSMSViewModel.swift
//  entourage
//
//  Created by Clement entourage on 17/11/2025.
//

import Foundation
import SwiftUI

class OnboardingSMSViewModel: ObservableObject {

    @Published var code: String = ""
    @Published var retryEnabled: Bool = false
    @Published var remaining: Int = 60

    let phone: String
    private var timer: Timer?

    init(phone: String) {
        self.phone = phone
        startTimer()
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - Phone formatting

    var formattedPhone: String {
        let digits = phone.filter { $0.isNumber }
        let normalized: String

        if digits.hasPrefix("0") {
            normalized = digits
        } else if digits.hasPrefix("33"), digits.count > 2 {
            normalized = "0" + digits.dropFirst(2)
        } else {
            normalized = digits
        }

        let limited = String(normalized.prefix(10))
        return limited.chunked(size: 2).joined(separator: " ")
    }

    var canModifyPhone: Bool {
        retryEnabled
    }

    // MARK: - Retry text

    var retryTitle: String {
        if retryEnabled {
            return NSLocalizedString("onboard_sms_view_wait_title", comment: "")
        } else {
            let formattedTime = timeFormatted
            let base = NSLocalizedString("onboard_sms_view_wait_countdown", comment: "")
            return String(format: base, formattedTime)
        }
    }

    private var timeFormatted: String {
        remaining < 10 ? "00:0\(remaining)" : "00:\(remaining)"
    }

    // MARK: - Timer

    func startTimer() {
        retryEnabled = false
        remaining = 60
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.remaining -= 1
            if self.remaining <= 0 {
                self.retryEnabled = true
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }

    func restartTimer() {
        startTimer()
    }

    // MARK: - Email

    func openEmail() {
        // Adresse de contact Entourage : adapte si besoin
        let email = "contact@entourage.social"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - String helpers

private extension String {
    func chunked(size: Int) -> [String] {
        guard size > 0 else { return [self] }
        var result: [String] = []
        var index = startIndex
        while index < endIndex {
            let end = self.index(index, offsetBy: size, limitedBy: endIndex) ?? endIndex
            result.append(String(self[index..<end]))
            index = end
        }
        return result
    }
}
