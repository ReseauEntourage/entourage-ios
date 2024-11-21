//
//  EnhancedOnboardingEnd.swift
//  entourage
//
//  Created by Clement entourage on 24/05/2024.
//

import Foundation
import UIKit
import Lottie
import MapKit

class EnhancedOnboardingEnd:UIViewController{
    
    //Outlet
    @IBOutlet weak var ui_lottiview: LottieAnimationView!
    @IBOutlet weak var ui_title_label: UILabel!
    @IBOutlet weak var ui_subtitle_label: UILabel!
    @IBOutlet weak var ui_btn_go_event: UIButton!
    
    
    //Variable
    let interests: [String]? = nil
    let concerns: [String]? = nil
    let involvements: [String]? = nil
    var currentFilter = EventActionLocationFilters()
    var haveEvents = false
    var selectedAddress: String = ""
    var selectedRadius: Float = 0
    var selectedCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        self.view.isHidden = true
        let starAnimation = LottieAnimation.named("congrats_animation")
        ui_lottiview.animation = starAnimation
        ui_lottiview.loopMode = .loop
        ui_lottiview.play()
        ui_title_label.text = "enhanced_onboarding_end_title".localized
        ui_subtitle_label.text = "enhanced_onboarding_end_subtitle".localized
        configureUserLocationAndRadius()
        configureOrangeButton(ui_btn_go_event, withTitle: "enhanced_onboarding_button_title_event".localized)
        ui_btn_go_event.addTarget(self, action: #selector(onEventClick), for: .touchUpInside)
        
        AnalyticsLoggerManager.logEvent(name: onboarding_end_view)
        if EnhancedOnboardingConfiguration.shared.preference != "contribution" {
            EventService.getSuggestFilteredEvents(
                currentPage: 1,
                per: 10,
                radius: self.selectedRadius,
                latitude: Float(self.selectedCoordinate?.latitude ?? 0.0),
                longitude: Float(self.selectedCoordinate?.longitude ?? 0.0),
                selectedItem: Array(EnhancedOnboardingConfiguration.shared.numberOfFilterForEvent)
            ) { events, error in
                guard let _events = events else{
                    self.haveEvents = false
                    return
                }
                var offLineEvent = [Event]()
                for _event in _events {
                    if !(_event.isOnline ?? false){
                        offLineEvent.append(_event)
                    }
                }
                if offLineEvent.isEmpty {
                    self.haveEvents = false
                    self.configureOnboardingEndView()
                }else{
                    self.haveEvents = true
                    self.configureOnboardingEndView()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    func configureUserLocationAndRadius() {
        if let user = UserDefaults.currentUser {
            self.selectedRadius = Float(user.radiusDistance ?? 40)
            self.selectedCoordinate = CLLocationCoordinate2D(latitude: user.addressPrimary?.latitude ?? 0, longitude: user.addressPrimary?.longitude ?? 0)
            self.selectedAddress = user.addressPrimary?.displayAddress ?? ""
        }
    }
    
    @objc func onEventClick(){
        AnalyticsLoggerManager.logEvent(name: onboarding_end_browse_events_clic)
        let eventFirebase = "onboarding_end_congrats_clic_" + (OnboardingEndChoicesManager.shared.categoryForButton ?? "")
        AnalyticsLoggerManager.logEvent(name: eventFirebase)
        let config = EnhancedOnboardingConfiguration.shared
        config.isFromOnboardingFromNormalWay = true
        AppState.navigateToMainApp()
        
        
    }
    
    func configureOnboardingEndView() {
         let choicesManager = OnboardingEndChoicesManager.shared
         var titleKey = "enhanced_onboarding_end_title"
         var subtitleKey = "enhanced_onboarding_end_subtitle"
         var buttonTitleKey = "enhanced_onboarding_button_title_event"
         
         // Vérification des choix utilisateur
         if let involvements = choicesManager.involvements {
             if involvements.contains("both_actions") {
                 titleKey = "onboarding_start_action_title"
                 subtitleKey = "onboarding_start_action_content"
                 buttonTitleKey = "onboarding_start_action_button"
                 OnboardingEndChoicesManager.shared.categoryForButton = "both_actions"
             } else if involvements.contains("outings") {
                 if(self.haveEvents){
                     titleKey = "onboarding_experience_event_title"
                     subtitleKey = "onboarding_experience_event_content"
                     buttonTitleKey = "onboarding_experience_event_button"
                     OnboardingEndChoicesManager.shared.categoryForButton = "event"
                 }else{
                     titleKey = "onboarding_no_event_title"
                     subtitleKey = "onboarding_no_event_content"
                     buttonTitleKey = "onboarding_no_event_button"
                     OnboardingEndChoicesManager.shared.categoryForButton = "no_event"
                 }
                 
             } else if involvements.contains("resources") {
                 titleKey = "onboarding_experience_resource_title"
                 subtitleKey = "onboarding_experience_resource_content"
                 buttonTitleKey = "onboarding_experience_resource_button"
                 OnboardingEndChoicesManager.shared.categoryForButton = "resources"
             } else if involvements.contains("neighborhoods") {
                 titleKey = "onboarding_ready_action_title"
                 subtitleKey = "onboarding_ready_action_content"
                 buttonTitleKey = "onboarding_ready_action_button"
                 OnboardingEndChoicesManager.shared.categoryForButton = "neighborhoods"
             }
         }
         // Affectation des valeurs localisées aux labels et boutons
         ui_title_label.text = titleKey.localized
         ui_subtitle_label.text = subtitleKey.localized
         configureOrangeButton(ui_btn_go_event, withTitle: buttonTitleKey.localized)
        let config = EnhancedOnboardingConfiguration.shared
        if config.isOnboardingFromSetting{
            config.isOnboardingFromSetting = false
            configureOrangeButton(ui_btn_go_event, withTitle: "button_title_for_re_onboarding_end".localized)
            OnboardingEndChoicesManager.shared.categoryForButton = ""
        }
        self.view.isHidden = false
     }
     

    
    
    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }

    func configureWhiteButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.appOrange.cgColor
        button.layer.borderWidth = 1
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }
    
    func presentViewControllerWithAnimation(identifier: String) {
            let storyboard = UIStoryboard(name: "EnhancedViewController", bundle: nil)
            if let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? UIViewController {
                viewController.modalPresentationStyle = .fullScreen
                viewController.modalTransitionStyle = .coverVertical
                present(viewController, animated: true, completion: nil)
            }
        }
}


class OnboardingEndChoicesManager {
    
    // Singleton partagé
    static let shared = OnboardingEndChoicesManager()
    
    // Variables pour stocker les choix utilisateur
    var interests: [String]?
    var concerns: [String]?
    var involvements: [String]?
    var categoryForButton:String?
    
    // Initialiseur privé pour empêcher les autres d'instancier ce singleton
    private init() {
        // Initialisation des variables si nécessaire
        self.interests = nil
        self.concerns = nil
        self.involvements = nil
    }
    
    // Méthode pour mettre à jour les choix utilisateur
    func updateChoices(interests: [String]?, concerns: [String]?, involvements: [String]?) {
        self.interests = interests
        self.concerns = concerns
        self.involvements = involvements
    }
}
