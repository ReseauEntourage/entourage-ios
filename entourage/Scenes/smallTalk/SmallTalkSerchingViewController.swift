import UIKit
import Lottie

class SmallTalkSearchingViewController: UIViewController {

    // Outlets
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_subtitle: UILabel!
    @IBOutlet weak var lottie_container: UIView!
    @IBOutlet weak var ui_defiling_label: UILabel!

    // Variables
    private var animationView: LottieAnimationView?
    private var steps: [String] = []
    private var currentStepIndex = 0
    private var timer: Timer?

    private var smallTalkRequestId: String?
    private var matchResponse: SmallTalkMatchResponse?
    private var matchResponseReceived = false
    private var animationPlayedOnce = false
    private var allStepsShown = false

    // MARK: - Configuration externe
    func configure(with id: String) {
        self.smallTalkRequestId = id
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Fonts
        ui_label_title.setFontTitle(size: 20)
        ui_label_subtitle.setFontBody(size: 15)
        ui_defiling_label.setFontTitle(size: 15)

        // Texts
        ui_label_title.text = NSLocalizedString("small_talk_searching_title", comment: "")
        ui_label_subtitle.text = NSLocalizedString("small_talk_searching_intro", comment: "")

        steps = [
            NSLocalizedString("small_talk_searching_step_1", comment: ""),
            NSLocalizedString("small_talk_searching_step_2", comment: ""),
            NSLocalizedString("small_talk_searching_step_3", comment: ""),
            NSLocalizedString("small_talk_searching_step_4", comment: "")
        ]

        ui_defiling_label.text = steps.first

        startTextLoop()
        startLottieAnimation()
        callMatchRequestIfNeeded()
    }

    private func startTextLoop() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.currentStepIndex += 1
            if self.currentStepIndex >= self.steps.count {
                self.allStepsShown = true
                self.timer?.invalidate()
            }

            let nextText = self.steps[self.currentStepIndex % self.steps.count]
            UIView.transition(with: self.ui_defiling_label, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.ui_defiling_label.text = nextText
            }, completion: nil)

            self.checkAndProceed()
        }
    }

    private func startLottieAnimation() {
        animationView = LottieAnimationView(name: "puzzle_mount")
        if let animationView = animationView {
            animationView.frame = lottie_container.bounds
            animationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .loop

            animationView.play { [weak self] _ in
                self?.animationPlayedOnce = true
                self?.checkAndProceed()
            }

            lottie_container.addSubview(animationView)
        }
    }

    private func callMatchRequestIfNeeded() {
        guard let id = smallTalkRequestId else { return }

        SmallTalkService.matchRequest(id: id) { [weak self] response, error in
            guard let self = self else { return }

            if let response = response {
                self.matchResponse = response
                self.matchResponseReceived = true
                self.checkAndProceed()
            } else {
                print("Erreur réseau matchRequest : \(error?.message ?? "inconnue")")
                // TODO: Ajouter gestion erreur (alerte, retry...)
            }
        }
    }

    private func checkAndProceed() {
        guard animationPlayedOnce, allStepsShown, matchResponseReceived else { return }

        // 🔁 Stop animations
        animationView?.stop()
        timer?.invalidate()

        // ✅ Transition vers l’étape suivante
        if let response = matchResponse {
            let nextVC = SmallTalkGroupFoundViewController() // Remplace par ton VC réel
            nextVC.configure(with: response)
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }

    deinit {
        timer?.invalidate()
    }
}
