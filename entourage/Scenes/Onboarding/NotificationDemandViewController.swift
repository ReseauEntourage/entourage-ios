import UIKit
import UserNotifications

class NotificationDemandViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_subtitle: UILabel!
    @IBOutlet weak var ui_btn_accept_notif: UIButton!
    @IBOutlet weak var ui_btn_disable_notif: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_title.text = "notif_demand_title".localized
        ui_subtitle.text = "notif_demand_subtitle".localized
        configureOrangeButton(ui_btn_accept_notif, withTitle: "notif_demand_btn_accept".localized)
        configureWhiteButton(ui_btn_disable_notif, withTitle: "notif_demand_btn_refuse".localized)
        
        // Ajoutez les actions aux boutons
        ui_btn_accept_notif.addTarget(self, action: #selector(didTapAcceptNotif), for: .touchUpInside)
        ui_btn_disable_notif.addTarget(self, action: #selector(didTapDisableNotif), for: .touchUpInside)
        
        // Vérifiez si les notifications sont déjà autorisées
        checkNotificationAuthorization()
    }
    
    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 24
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 13)
        button.clipsToBounds = true
    }

    func configureWhiteButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.appOrange.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 24
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 13)
        button.clipsToBounds = true
    }
    
    func checkNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    // Notifications déjà autorisées, ferme la vue
                    self?.goHomeMain()
                case .denied, .notDetermined:
                    // L'utilisateur doit choisir, ne rien faire
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    @objc func didTapAcceptNotif() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    // Autorisation accordée, ferme la vue
                    UIApplication.shared.registerForRemoteNotifications()
                    self?.goHomeMain()
                } else {
                    // Autorisation refusée, reste sur l'écran
                    print("Notifications denied: \(String(describing: error))")
                }
            }
        }
    }

    @objc func didTapDisableNotif() {
        // L'utilisateur refuse explicitement les notifications
        self.dismiss(animated: true, completion: nil)
    }
    
    func goHomeMain() {
        AppState.navigateToMainApp()
    }
}

class NotificationDisplayManager {
    static let shared = NotificationDisplayManager()
    var hasBeenDisplayed: Bool = false

    private init() {}
}
