import UIKit
import UserNotifications

class ParamsNotifsViewController: BasePopViewController {

    @IBOutlet weak var ui_switch_notifs: UISwitch!
    @IBOutlet weak var ui_title_notifs: UILabel!
    @IBOutlet weak var ui_switch_messages: UISwitch!
    @IBOutlet weak var ui_title_messages: UILabel!
    @IBOutlet weak var ui_switch_groups: UISwitch!
    @IBOutlet weak var ui_title_groups: UILabel!
    @IBOutlet weak var ui_switch_events: UISwitch!
    @IBOutlet weak var ui_title_events: UILabel!
    @IBOutlet weak var ui_switch_actions: UISwitch!
    @IBOutlet weak var ui_title_actions: UILabel!
    @IBOutlet weak var ui_bt_validate: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_top_view.populateView(title: "params_notifs_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
        
        ui_title_notifs.text = "param_notifs_switch_notifs".localized
        ui_title_messages.text = "param_notifs_switch_messages".localized
        ui_title_groups.text = "param_notifs_switch_groups".localized
        ui_title_events.text = "param_notifs_switch_events".localized
        ui_title_actions.text = "param_notifs_switch_actions".localized
        
        ui_title_notifs.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange(size: 16))
        ui_title_messages.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_title_groups.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_title_events.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_title_actions.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        ui_bt_validate.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 18)
        ui_bt_validate.titleLabel?.textColor = .white
        ui_bt_validate.layer.cornerRadius = ui_bt_validate.frame.height / 2
        ui_bt_validate.setTitle("param_notifs_validate".localized, for: .normal)
        
        checkSystemNotificationSettings()
    }
    
    func checkSystemNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    self.getNotifsInfos()
                } else {
                    self.updateSwitchs(notifPermissions: nil)
                }
            }
        }
    }

    func getNotifsInfos() {
        HomeService.getNotifsPermissions { notifPerms, error in
            self.updateSwitchs(notifPermissions: notifPerms)
        }
    }
    
    func updateSwitchs(notifPermissions: NotifInAppPermission?) {
        if let notifPermissions = notifPermissions {
            ui_switch_messages.setOn(notifPermissions.chat_message, animated: true)
            ui_switch_groups.setOn(notifPermissions.neighborhood, animated: true)
            ui_switch_events.setOn(notifPermissions.outing, animated: true)
            ui_switch_actions.setOn(notifPermissions.action, animated: true)
            ui_switch_notifs.setOn(notifPermissions.allNotifsOn(), animated: true)
        } else {
            ui_switch_notifs.setOn(false, animated: true)
            setAllSwitch(isOn: false)
        }
    }
    
    @IBAction func action_validate(_ sender: Any) {
        var notifPermissions = NotifInAppPermission()
        notifPermissions.action = ui_switch_actions.isOn
        notifPermissions.neighborhood = ui_switch_groups.isOn
        notifPermissions.outing = ui_switch_events.isOn
        notifPermissions.chat_message = ui_switch_messages.isOn
        
        HomeService.updateNotifsPermissions(notifPerms: notifPermissions) { error in
            self.goBack()
        }
    }
    
    @IBAction func action_all(_ sender: UISwitch) {
        if sender.isOn {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                DispatchQueue.main.async {
                    if settings.authorizationStatus == .denied {
                        // Redirige vers les paramètres de l'application
                        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(appSettings)
                        }
                    } else {
                        self.setAllSwitch(isOn: true)
                    }
                }
            }
        } else {
            setAllSwitch(isOn: false)
        }
    }
    
    @IBAction func action_switch(_ sender: Any) {
        var notifPermissions = NotifInAppPermission()
        notifPermissions.action = ui_switch_actions.isOn
        notifPermissions.neighborhood = ui_switch_groups.isOn
        notifPermissions.outing = ui_switch_events.isOn
        notifPermissions.chat_message = ui_switch_messages.isOn
        
        // Met à jour l'état du switch général (OR au lieu d'AND)
        let isAnySwitchOn = notifPermissions.action || notifPermissions.neighborhood || notifPermissions.outing || notifPermissions.chat_message
        ui_switch_notifs.setOn(isAnySwitchOn, animated: true)
    }
    
    func setAllSwitch(isOn: Bool) {
        ui_switch_messages.setOn(isOn, animated: true)
        ui_switch_groups.setOn(isOn, animated: true)
        ui_switch_events.setOn(isOn, animated: true)
        ui_switch_actions.setOn(isOn, animated: true)
    }
}

// MARK: - MainUserProfileTopCellDelegate -
extension ParamsNotifsViewController: MJNavBackViewDelegate {
    func goBack() {
        self.dismiss(animated: true)
    }
}
