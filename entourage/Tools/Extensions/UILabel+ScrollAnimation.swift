import UIKit

extension UILabel {
    func animateCount(to value: Int, duration: TimeInterval = 0.5, prefix: String = "") {
        let startValue = 0
        let steps = 20
        let interval = duration / Double(steps)

        var currentStep = 0

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            currentStep += 1
            let progress = Double(currentStep) / Double(steps)
            let currentValue = Int(Double(startValue) + (Double(value - startValue) * progress))

            self.text = "\(prefix)\(currentValue)"

            if currentStep >= steps {
                self.text = "\(prefix)\(value)"
                timer.invalidate()
            }
        }
    }
}
