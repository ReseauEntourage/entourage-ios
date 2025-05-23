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
    private var userRequest: UserSmallTalkRequest?

    // MARK: - Configuration externe
    func configure(with request: UserSmallTalkRequest) {
        self.userRequest = request
        self.smallTalkRequestId = request.uuid_v2
    }

    // MARK: - Lifecycle
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

    // MARK: - Animations & Loop
    private func startTextLoop() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.currentStepIndex += 1
            if self.currentStepIndex >= self.steps.count {
                self.allStepsShown = true
                self.timer?.invalidate()
                self.checkAndProceed() // ✅ appel ajouté ici
            }

            let nextText = self.steps[self.currentStepIndex % self.steps.count]
            UIView.transition(with: self.ui_defiling_label, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.ui_defiling_label.text = nextText
            }, completion: nil)
        }
    }

    private func startLottieAnimation() {
        animationView = LottieAnimationView(name: "puzzle_mount")
        if let animationView = animationView {
            animationView.frame = lottie_container.bounds
            animationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .loop
            animationView.play()

            self.animationPlayedOnce = true // ✅ déclenché immédiatement après lancement
            self.checkAndProceed()
            lottie_container.addSubview(animationView)
        }
    }

    // MARK: - Appel Réseau
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
                // TODO: Ajouter gestion erreur (alerte, retry…)
            }
        }
    }

    // MARK: - Synchronisation finale
    private func checkAndProceed() {
        guard animationPlayedOnce, allStepsShown, matchResponseReceived else { return }

        animationView?.stop()
        timer?.invalidate()

        guard let response = matchResponse else { return }

        let sb = UIStoryboard(name: "SmallTalk", bundle: nil)

        if response.match {
            if let nextVC = sb.instantiateViewController(withIdentifier: "SmallTalkGroupFoundViewController") as? SmallTalkGroupFoundViewController {
                nextVC.configure(with: response)
                nextVC.modalPresentationStyle = .fullScreen
                self.present(nextVC, animated: true)
            }
        } else {
            if let nextVC = sb.instantiateViewController(withIdentifier: "SmallTalkAlmostMatchingViewController") as? SmallTalkAlmostMatchingViewController,
               let userRequest = self.userRequest {

                let group = userRequest.match_format ?? "one"
                let gender = userRequest.match_gender ?? false
                let locality = userRequest.match_locality ?? false

                nextVC.configure(
                    with: userRequest.uuid_v2 ?? "",
                    group: group,
                    gender: gender,
                    locality: locality
                )
                nextVC.modalPresentationStyle = .fullScreen
                self.present(nextVC, animated: true)
            }
        }
    }

    // MARK: - Cleanup
    deinit {
        timer?.invalidate()
    }
}
