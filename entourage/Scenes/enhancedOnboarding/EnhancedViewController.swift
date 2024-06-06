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
            OnboardingChoice(id: "sharing_time", img: "ic_onboarding_entraide_share", title: "Temps de partage"),
            OnboardingChoice(id: "material_donations", img: "ic_onboarding_entraide_material", title: "Dons matériels"),
            OnboardingChoice(id: "services", img: "ic_onboarding_entraide_service", title: "Proposition de services")
        ]
        
        
        // Initialize involvement choices
        print("config " + EnhancedOnboardingConfiguration.shared.preference)
        if EnhancedOnboardingConfiguration.shared.preference == "contribution"{
            involvementChoices = [
                OnboardingChoice(id: "outings", img: "ic_onboarding_action_wish_convivialite", title: "Participer à des événements de convivialité"),
                OnboardingChoice(id: "both_actions", img: "ic_onboarding_action_wish_coup_de_pouce", title: "Solliciter un coup de pouce"),
                OnboardingChoice(id: "neighborhoods", img: "ic_onboarding_action_wish_discussion", title: "Rejoindre un groupe de voisins et tisser des liens"),
                OnboardingChoice(id: "pois", img: "ic_onboarding_action_wish_discussion", title: "Trouver des structures solidaires à proximité")
            ]
        }else{
            involvementChoices = [
                OnboardingChoice(id: "resources", img: "ic_onboarding_action_wish_sensibilisation", title: "Apprendre avec des contenus pédagogiques"),
                OnboardingChoice(id: "outings", img: "ic_onboarding_action_wish_convivialite", title: "Participer à des événements de convivialité"),
                OnboardingChoice(id: "both_actions", img: "ic_onboarding_action_wish_coup_de_pouce", title: "Donner ou solliciter un coup de pouce"),
                OnboardingChoice(id: "neighborhoods", img: "ic_onboarding_action_wish_discussion", title: "Rejoindre un groupe de voisins et tisser des liens")
            ]
        }
        // Initialize interest choices
        interestChoices = [
            OnboardingChoice(id: "sport", img: "interest_jeux", title: "Sport"),
            OnboardingChoice(id: "animaux", img: "interest_don-materiel", title: "Animaux"),
            OnboardingChoice(id: "marauding", img: "interest_rencontre-nomade", title: "Rencontres nomades"),
            OnboardingChoice(id: "cuisine", img: "interest_cuisine", title: "Cuisine"),
            OnboardingChoice(id: "jeux", img: "interest_jeux", title: "Jeux"),
            OnboardingChoice(id: "activites", img: "interest_activite-manuelle", title: "Activités manuelles"),
            OnboardingChoice(id: "bien-etre", img: "interest_bien-etre", title: "Bien-être"),
            OnboardingChoice(id: "nature", img: "interest_nature", title: "Nature"),
            OnboardingChoice(id: "culture", img: "interest_moment de partage", title: "Art & Culture"),
            OnboardingChoice(id: "other", img: "interest_autre", title: "Autre")
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
            tableDTO.append(.title(title: "Mes centres d’intérêts", subtitle: "Pour vous aider à trouver des activités qui vous correspondent, dites-nous ce qui vous intéresse."))
            tableDTO.append(.collectionViewCell(choices: interestChoices))
        case .concern:
            AnalyticsLoggerManager.logEvent(name: onboarding_donations_categories_view)
            tableDTO.append(.backArrow)
            tableDTO.append(.title(title: "Mes catégories d’entraide", subtitle: "Sélectionnez les catégories d'entraide que vous souhaitez voir en priorité."))
            concernChoices.forEach { choice in
                tableDTO.append(.fullSizeCell(choice: choice, isSelected: selectedIds.contains(choice.id)))
            }
        case .involvement:
            AnalyticsLoggerManager.logEvent(name: onboarding_actions_view)
            tableDTO.append(.backArrow)
            tableDTO.append(.title(title: "Comment souhaitez-vous agir au sein de la communauté Entourage ?", subtitle: "(Eh oui, vous avez le droit de choisir plusieurs options !)"))
            involvementChoices.forEach { choice in
                tableDTO.append(.fullSizeCell(choice: choice, isSelected: selectedIds.contains(choice.id)))
            }
        }
        
        tableDTO.append(.buttonCell)
        ui_tableview.reloadData()
        DispatchQueue.main.async {
            if self.tableDTO.count > 0 {
                self.ui_tableview.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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


class EnhancedOnboardingConfiguration {
    static let shared = EnhancedOnboardingConfiguration()
    var isInterestsFromSetting = false
    var isOnboardingFromSetting = false
    var isFromOnboardingFromNormalWay = false
    var shouldSendOnboardingFromNormalWay = false
    var preference:String = ""
    private init() {}

}
