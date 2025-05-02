//
//  OnboardingEndViewController.swift
//  entourage
//
//  Created by You on 02/12/2022.
//

import UIKit

class OnboardingEndViewController: UIViewController {

    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_desc: UILabel!
    @IBOutlet weak var ui_bt_go: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange(size: 24))
        ui_desc.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 17))
        ui_bt_go.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc(size: 15))
        
        ui_bt_go.layer.cornerRadius = ui_bt_go.frame.height / 2
        
        ui_title.text = "onboard_end_title".localized
        ui_desc.text = "onboard_end_subtitle".localized
        ui_bt_go.setTitle("onboard_end_button".localized, for: .normal)
        configureOrangeButton(ui_bt_go, withTitle: "onboard_end_button".localized)
        AnalyticsLoggerManager.logEvent(name: Onboard_end)
    }
    
    override func viewWillLayoutSubviews() {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
      }
    
    func showPopNotification() {
        AppState.showPopNotification { [weak self] isAccept in
            DispatchQueue.main.async {
                self?.goHomeMain()
            }
        }
    }
    
    @IBAction func action_go(_ sender: Any) {
        let config = EnhancedOnboardingConfiguration.shared
        config.shouldSendOnboardingFromNormalWay = true
        goHomeMain()
    }
    
    func goHomeMain() {
        let user = UserDefaults.currentUser
        UserService.getDetailsForUser(userId: user?.uuid ?? "") { returnUser, error in
            if let returnUser = returnUser {
                var newUser = returnUser
                newUser.phone = user?.phone
                UserDefaults.currentUser = newUser
            }
            DispatchQueue.main.async {
                let sb = UIStoryboard.init(name: StoryboardName.onboarding, bundle: nil)
                if let vc = sb.instantiateViewController(withIdentifier: "NotificationDemandViewController") as? NotificationDemandViewController {
                    self.present(vc, animated: true, completion: nil)
                } else {
                    print("ViewController with identifier 'NotificationDemandViewController' not found")
                }
            }
        }
    }

}
