import Foundation
import UIKit

class OnboardingChoice {
    var id: String
    var img: String
    var title: String

    init(id: String, img: String, title: String) {
        self.id = id
        self.img = img
        self.title = title
    }
}

enum EnhancedOnboardingTableDTO {
    case title(title: String, subtitle: String)
    case fullSizeCell(choice: OnboardingChoice, isSelected: Bool)
    case collectionViewCell(choices: [OnboardingChoice])
    case buttonCell
    case backArrow
}

enum EnhancedOnboardingMode {
    case interest // centre d'intérêt
    case concern // Entraides
    case involvement // envie d'agir
}

class EnhancedViewController: UIViewController {
    
    // OUTLET
    @IBOutlet weak var ui_tableview: UITableView!
    
    // Variables
    var tableDTO = [EnhancedOnboardingTableDTO]()
    var mode: EnhancedOnboardingMode = .involvement
    var selectedIds = Set<String>()
    
    var concernChoices: [OnboardingChoice] = []
    var involvementChoices: [OnboardingChoice] = []
    var interestChoices: [OnboardingChoice] = []
    var returnHome = false
    var hasChangedMod = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        ui_tableview.register(UINib(nibName: "EnhancedOnboardingTitle", bundle: nil), forCellReuseIdentifier: "titleCell")
        ui_tableview.register(UINib(nibName: "EnhancedFullSizeCell", bundle: nil), forCellReuseIdentifier: "fullSizeCell")
        ui_tableview.register(UINib(nibName: "EnhancedOnboardingCollectionCell", bundle: nil), forCellReuseIdentifier: "collectionViewCell")
        ui_tableview.register(UINib(nibName: "EnahancedOnboardingButtonCell", bundle: nil), forCellReuseIdentifier: "buttonCell")
        ui_tableview.register(UINib(nibName: "EnhancecOnboardingBackCell", bundle: nil), forCellReuseIdentifier: "enhancecOnboardingBackCell")
        
        // Assign delegates
        ui_tableview.delegate = self
        ui_tableview.dataSource = self
        
        // Initialize choices
        initializeChoices()
        
        // Load data for the initial mode
        loadDTO()
    }
    
    private func initializeChoices() {
        guard let currentUser = UserDefaults.currentUser else {
            return
        }
        // Initialize concern choices
        concernChoices = [
            OnboardingChoice(id: "sharing_time", img: "img_asset_onboarding_share", title: NSLocalizedString("enhanced_onboarding_sharing_time", comment: "")),
            OnboardingChoice(id: "material_donations", img: "img_asset_onboarding_entraide", title: NSLocalizedString("enhanced_onboarding_material_donations", comment: "")),
            OnboardingChoice(id: "services", img: "img_asset_onboarding_service", title: NSLocalizedString("enhanced_onboarding_services", comment: ""))
        ]
        
        // Initialize involvement choices
        if EnhancedOnboardingConfiguration.shared.preference == "contribution"{
            involvementChoices = [
                OnboardingChoice(id: "outings", img: "img_asset_onboarding_convivialite", title: NSLocalizedString("enhanced_onboarding_participate_events", comment: "")),
                OnboardingChoice(id: "both_actions", img: "img_asset_onboarding_pouce", title: NSLocalizedString("enhanced_onboarding_solicit_help", comment: "")),
                OnboardingChoice(id: "neighborhoods", img: "img_asset_onboarding_discussion", title: NSLocalizedString("enhanced_onboarding_join_neighborhoods", comment: "")),
                OnboardingChoice(id: "pois", img: "img_asset_onboarding_pois", title: NSLocalizedString("enhanced_onboarding_find_structures", comment: ""))
            ]
        }else{
            involvementChoices = [
                OnboardingChoice(id: "resources", img: "img_asset_onboarding_sensib", title: NSLocalizedString("enhanced_onboarding_learn_content", comment: "")),
                OnboardingChoice(id: "outings", img: "img_asset_onboarding_convivialite", title: NSLocalizedString("enhanced_onboarding_participate_events", comment: "")),
                OnboardingChoice(id: "both_actions", img: "img_asset_onboarding_pouce", title: NSLocalizedString("enhanced_onboarding_give_help", comment: "")),
                OnboardingChoice(id: "neighborhoods", img: "img_asset_onboarding_discussion", title: NSLocalizedString("enhanced_onboarding_join_neighborhoods", comment: ""))
            ]
        }
        // Initialize interest choices
        interestChoices = [
            OnboardingChoice(id: "sport", img: "interest_sport", title: NSLocalizedString("enhanced_onboarding_interest_sport", comment: "")),
            OnboardingChoice(id: "animaux", img: "interest_animaux", title: NSLocalizedString("enhanced_onboarding_interest_animals", comment: "")),
            OnboardingChoice(id: "marauding", img: "interest_rencontre-nomade", title: NSLocalizedString("enhanced_onboarding_interest_social_marauding", comment: "")),
            OnboardingChoice(id: "cuisine", img: "interest_cuisine", title: NSLocalizedString("enhanced_onboarding_interest_cooking", comment: "")),
            OnboardingChoice(id: "jeux", img: "interest_jeux", title: NSLocalizedString("enhanced_onboarding_interest_games", comment: "")),
            OnboardingChoice(id: "activites", img: "interest_activite-manuelle", title: NSLocalizedString("enhanced_onboarding_interest_manual_activities", comment: "")),
            OnboardingChoice(id: "bien-etre", img: "interest_bien-etre", title: NSLocalizedString("enhanced_onboarding_interest_wellbeing", comment: "")),
            OnboardingChoice(id: "nature", img: "interest_nature", title: NSLocalizedString("enhanced_onboarding_interest_nature", comment: "")),
            OnboardingChoice(id: "culture", img: "interest_art", title: NSLocalizedString("enhanced_onboarding_interest_art_culture", comment: "")),
            OnboardingChoice(id: "other", img: "interest_autre", title: NSLocalizedString("enhanced_onboarding_interest_other", comment: ""))
        ]
        
        let interests = Set(currentUser.interests ?? [])
        let concerns = Set(currentUser.concerns ?? [])
        let involvements = Set(currentUser.involvements ?? [])
        selectedIds = interests.union(concerns).union(involvements)
    }
    
    private func loadDTO() {
        tableDTO.removeAll()
        
        switch self.mode {
        case .interest:
            AnalyticsLoggerManager.logEvent(name: onboarding_interests_view)
            tableDTO.append(.backArrow)
            tableDTO.append(.title(title: NSLocalizedString("enhanced_onboarding_my_interests", comment: ""), subtitle: NSLocalizedString("enhanced_onboarding_find_activities", comment: "")))
            tableDTO.append(.collectionViewCell(choices: interestChoices))
        case .concern:
            AnalyticsLoggerManager.logEvent(name: onboarding_donations_categories_view)
            tableDTO.append(.backArrow)
            tableDTO.append(.title(title: NSLocalizedString("enhanced_onboarding_my_concerns", comment: ""), subtitle: NSLocalizedString("enhanced_onboarding_select_concerns", comment: "")))
            concernChoices.forEach { choice in
                tableDTO.append(.fullSizeCell(choice: choice, isSelected: selectedIds.contains(choice.id)))
            }
        case .involvement:
            AnalyticsLoggerManager.logEvent(name: onboarding_actions_view)
            tableDTO.append(.backArrow)
            tableDTO.append(.title(title: NSLocalizedString("enhanced_onboarding_how_to_act", comment: ""), subtitle: NSLocalizedString("enhanced_onboarding_multiple_options", comment: "")))
            involvementChoices.forEach { choice in
                tableDTO.append(.fullSizeCell(choice: choice, isSelected: selectedIds.contains(choice.id)))
            }
        }
        
        tableDTO.append(.buttonCell)
        ui_tableview.reloadData()
        if hasChangedMod {
            hasChangedMod = false
            DispatchQueue.main.async {
                if self.tableDTO.count > 0 {
                    self.ui_tableview.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            }
        }
    }
    
    func presentViewControllerWithAnimation(identifier: String) {
        let storyboard = UIStoryboard(name: "EnhancedOnboarding", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? UIViewController {
            viewController.modalPresentationStyle = .fullScreen
            viewController.modalTransitionStyle = .coverVertical
            present(viewController, animated: true, completion: nil)
        }
    }
    
    func updateUserChoices() {
        let interests = interestChoices.filter { selectedIds.contains($0.id) }.map { $0.id }
        let concerns = concernChoices.filter { selectedIds.contains($0.id) }.map { $0.id }
        let involvements = involvementChoices.filter { selectedIds.contains($0.id) }.map { $0.id }
        UserService.updateUserChoices(interests: interests, concerns: concerns, involvements: involvements) { user, error in
            if let error = error {
                print("Error updating user choices: \(error)")
                // Handle error
            } else {
                print("Successfully updated user choices")
                if let _user = user {
                    UserDefaults.updateCurrentUser(newUser: _user)
                }
                if self.returnHome {
                    DispatchQueue.main.async {
                        AppState.navigateToMainApp()
                    }
                }else{
                    DispatchQueue.main.async {
                        let config = EnhancedOnboardingConfiguration.shared
                        if config.isInterestsFromSetting {
                            AppState.navigateToMainApp()
                        }else{
                            OnboardingEndChoicesManager.shared.updateChoices(interests: interests, concerns: concerns, involvements: involvements)
                            self.presentViewControllerWithAnimation(identifier: "enhancedOnboardingEnd")
                        }
                    }
                }
                // Handle success, possibly update UI or proceed to next step
            }
        }
    }
    
}

extension EnhancedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDTO.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dto = tableDTO[indexPath.row]
        
        switch dto {
        case .title(let title, let subtitle):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as? EnhancedOnboardingTitle else {
                return UITableViewCell()
            }
            cell.configure(title: title, subtitle: subtitle)
            cell.selectionStyle = .none
            return cell
            
        case .fullSizeCell(let choice, let isSelected):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "fullSizeCell", for: indexPath) as? EnhancedFullSizeCell else {
                return UITableViewCell()
            }
            cell.configure(choice: choice, isSelected: isSelected)
            cell.selectionStyle = .none
            return cell
            
        case .collectionViewCell(let choices):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "collectionViewCell", for: indexPath) as? EnhancedOnboardingCollectionCell else {
                return UITableViewCell()
            }
            cell.setItems(choices, selectedIds: selectedIds)
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
            
        case .buttonCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath) as? EnahancedOnboardingButtonCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.selectionStyle = .none
            cell.configure()
            return cell
        case .backArrow:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "enhancecOnboardingBackCell", for: indexPath) as? EnhancecOnboardingBackCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableDTO[indexPath.row] {
        case .title:
            return UITableView.automaticDimension
        case .fullSizeCell:
            return UITableView.automaticDimension
        case .collectionViewCell:
            return 900 // Adjust this based on your requirements
        case .buttonCell:
            return UITableView.automaticDimension
        case .backArrow:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dto = tableDTO[indexPath.row]
        
        switch dto {
        case .fullSizeCell(let choice, _):
            if selectedIds.contains(choice.id) {
                selectedIds.remove(choice.id)
            } else {
                selectedIds.insert(choice.id)
            }
            loadDTO() // Reload to update selection state
        case .backArrow:
            hasChangedMod = true
            let config = EnhancedOnboardingConfiguration.shared
            if config.isInterestsFromSetting {
                self.dismiss(animated: true) {
                    config.isInterestsFromSetting = false
                }
            }else{
                switch mode{
                case .interest:
                    mode = .involvement
                case .concern:
                    mode = .interest
                case .involvement:
                    self.presentViewControllerWithAnimation(identifier: "enhancedOnboardingIntro")
                }
                self.loadDTO()
            }
        default:
            break
        }
    }
}

extension EnhancedViewController: EnhancedOnboardingButtonDelegate {
    func onConfigureLaterClick() {
        switch mode{
        case .interest:
            AnalyticsLoggerManager.logEvent(name: onboarding_interests_config_later_clic)
        case .concern:
            AnalyticsLoggerManager.logEvent(name: onboarding_donations_categories_config_later_clic)
        case .involvement:
            AnalyticsLoggerManager.logEvent(name: onboarding_actions_config_later_clic)
        }
        self.returnHome = true
        self.updateUserChoices()
    }
    
    func onNextClick() {
        hasChangedMod = true
        switch mode{
        case .interest:
            AnalyticsLoggerManager.logEvent(name: onboarding_interests_next_clic)
        case .concern:
            AnalyticsLoggerManager.logEvent(name: onboarding_donations_categories_next_clic)
        case .involvement:
            AnalyticsLoggerManager.logEvent(name: onboarding_actions_next_clic)
        }
        
        let config = EnhancedOnboardingConfiguration.shared
        if config.isInterestsFromSetting {
            self.updateUserChoices()
        }else{
            switch mode {
            case .involvement:
                mode = .interest
            case .interest:
                mode = .concern
            case .concern:
                self.returnHome = false
                self.updateUserChoices()
            }
            loadDTO()
        }
    }
}

extension EnhancedViewController: EnhancedOnboardingCollectionCellDelegate {
    func collectionCell(didSelect choice: OnboardingChoice) {
        if selectedIds.contains(choice.id) {
            selectedIds.remove(choice.id)
        } else {
            selectedIds.insert(choice.id)
        }
        loadDTO() // Reload to update selection state
    }
}

extension EnhancedViewController {
    func generateDaysAndHours() -> (days: [String], hours: [String]) {
        let days = [
            "day_monday".localized,
            "day_tuesday".localized,
            "day_wednesday".localized,
            "day_thursday".localized,
            "day_friday".localized,
            "day_saturday".localized,
            "day_sunday".localized
        ]
        
        let hours = [
            "hour_morning".localized,
            "hour_afternoon".localized,
            "hour_evening".localized
        ]
        
        return (days, hours)
    }
}

class EnhancedOnboardingConfiguration {
    static let shared = EnhancedOnboardingConfiguration()
    var isInterestsFromSetting = false
    var isOnboardingFromSetting = false
    var isFromOnboardingFromNormalWay = false
    var shouldSendOnboardingFromNormalWay = false
    var preference:String = ""
    private init() {}

}

extension EnhancedViewController {
    func generateDaysAndHours() -> (days: [String], hours: [String]) {
        let days = [
            "day_monday".localized,
            "day_tuesday".localized,
            "day_wednesday".localized,
            "day_thursday".localized,
            "day_friday".localized,
            "day_saturday".localized,
            "day_sunday".localized
        ]
        
        let hours = [
            "hour_morning".localized,
            "hour_afternoon".localized,
            "hour_evening".localized
        ]
        
        return (days, hours)
    }
}
