import Foundation
import UIKit

// MARK: - Models & Enums

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
    case choiceDayCell(days: [String], selectedDays: Set<Int>)
    case associationPresentation
    case backArrow
}

enum EnhancedOnboardingMode {
    case interest
    case concern
    case involvement
    case choiceDisponibility
    case associationPresentation
}

// MARK: - Main Controller

class EnhancedViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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

    var selectedDays = Set<Int>()
    var selectedHours = Set<Int>()

    var isAssociationGoal: Bool = false
    var associationLogoImage: UIImage?
    var associationDescription: String?
    
    // Référence pour le bouton "Sticky"
    var stickyButtonView: EnahancedOnboardingButtonCell?
    
    // MARK: - Association Logic Variables
    private let associationPresenter = AssociationPresenter()
    private var currentPartnerId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Enregistrement des cellules
        ui_tableview.register(UINib(nibName: "EnhancedOnboardingTitle", bundle: nil), forCellReuseIdentifier: "titleCell")
        ui_tableview.register(UINib(nibName: "EnhancedFullSizeCell", bundle: nil), forCellReuseIdentifier: "fullSizeCell")
        ui_tableview.register(UINib(nibName: "EnhancedOnboardingCollectionCell", bundle: nil), forCellReuseIdentifier: "collectionViewCell")
        ui_tableview.register(UINib(nibName: "EnhancecOnboardingBackCell", bundle: nil), forCellReuseIdentifier: "enhancecOnboardingBackCell")
        ui_tableview.register(UINib(nibName: "ChoiceDayCell", bundle: nil), forCellReuseIdentifier: "ChoiceDayCell")
        ui_tableview.register(AssociationPresentationCell.self, forCellReuseIdentifier: "associationPresentationCell")

        ui_tableview.delegate = self
        ui_tableview.dataSource = self
        
        // Configuration de l'interface
        setupStickyFooter()
        preconfigureAvailability()
        initializeChoices()
        setupAssociationLogic()
        loadDTO()
    }
    
    /// Configuration initiale pour la logique Association
    private func setupAssociationLogic() {
        associationPresenter.delegate = self
        
        if let user = UserDefaults.currentUser,
           let partner = user.partner,
           let pid = partner.aid {
            self.currentPartnerId = pid
        }
    }
    
    /// Cette méthode crée le bouton et le "colle" en bas de l'écran
    private func setupStickyFooter() {
        guard let buttonView = Bundle.main.loadNibNamed("EnahancedOnboardingButtonCell", owner: self, options: nil)?.first as? EnahancedOnboardingButtonCell else {
            return
        }
        
        buttonView.delegate = self
        buttonView.configure()
        if EnhancedOnboardingConfiguration.shared.isInterestsFromSetting {
            buttonView.configureForMainFilter()
        }
        
        self.view.addSubview(buttonView)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        self.stickyButtonView = buttonView
        
        let height: CGFloat = 130
        
        NSLayoutConstraint.activate([
            buttonView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            buttonView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            buttonView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            buttonView.heightAnchor.constraint(equalToConstant: height)
        ])
        
        ui_tableview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
        ui_tableview.scrollIndicatorInsets = ui_tableview.contentInset
    }

    private func preconfigureAvailability() {
        if let userAvailability = UserDefaults.currentUser?.availability {
            for (dayKey, timeRanges) in userAvailability {
                if let dayIndex = Int(dayKey) { selectedDays.insert(dayIndex - 1) }
                for timeRange in timeRanges {
                    let slot: Int? = {
                        switch timeRange {
                        case "09:00-12:00": return 0
                        case "14:00-18:00": return 1
                        case "18:00-21:00": return 2
                        default: return nil
                        }
                    }()
                    if let s = slot { selectedHours.insert(s) }
                }
            }
        }
    }

    private func initializeChoices() {
        guard let currentUser = UserDefaults.currentUser else { return }
        
        concernChoices = [
            OnboardingChoice(id: "sharing_time", img: "img_asset_onboarding_share", title: NSLocalizedString("enhanced_onboarding_sharing_time", comment: "")),
            OnboardingChoice(id: "material_donations", img: "img_asset_onboarding_entraide", title: NSLocalizedString("enhanced_onboarding_material_donations", comment: "")),
            OnboardingChoice(id: "services", img: "img_asset_onboarding_service", title: NSLocalizedString("enhanced_onboarding_services", comment: ""))
        ]

        if isAssociationGoal {
            // Mapping ID et Icons basés sur la logique Android (Action Wishes / Orientations)
            // share -> "resources" icon (Android) -> img_asset_onboarding_sensib
            // guide -> "outings" icon (Android) -> img_asset_onboarding_convivialite
            // both_actions -> "actions" icon (Android) -> img_asset_onboarding_pouce
            
            involvementChoices = [
                OnboardingChoice(id: "share", img: "img_asset_onboarding_sensib", title: "Relayer vos événements de convivialité sur l'application"),
                OnboardingChoice(id: "guide", img: "img_asset_onboarding_convivialite", title: "Orienter vos bénéficiaires aux événements de convivialité"),
                OnboardingChoice(id: "both_actions", img: "img_asset_onboarding_pouce", title: "Donner ou solliciter un coup de pouce")
            ]
        } else {
            let pref = EnhancedOnboardingConfiguration.shared.preference
            involvementChoices = (pref == "contribution") ? [
                OnboardingChoice(id: "outings", img: "img_asset_onboarding_convivialite", title: NSLocalizedString("enhanced_onboarding_participate_events", comment: "")),
                OnboardingChoice(id: "both_actions", img: "img_asset_onboarding_pouce", title: NSLocalizedString("enhanced_onboarding_solicit_help", comment: "")),
                OnboardingChoice(id: "neighborhoods", img: "img_asset_onboarding_discussion", title: NSLocalizedString("enhanced_onboarding_join_neighborhoods", comment: "")),
                OnboardingChoice(id: "pois", img: "img_asset_onboarding_pois", title: NSLocalizedString("enhanced_onboarding_find_structures", comment: ""))
            ] : [
                OnboardingChoice(id: "resources", img: "img_asset_onboarding_sensib", title: NSLocalizedString("enhanced_onboarding_learn_content", comment: "")),
                OnboardingChoice(id: "outings", img: "img_asset_onboarding_convivialite", title: NSLocalizedString("enhanced_onboarding_participate_events", comment: "")),
                OnboardingChoice(id: "both_actions", img: "img_asset_onboarding_pouce", title: NSLocalizedString("enhanced_onboarding_give_help", comment: "")),
                OnboardingChoice(id: "neighborhoods", img: "img_asset_onboarding_discussion", title: NSLocalizedString("enhanced_onboarding_join_neighborhoods", comment: ""))
            ]
        }

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
        let orientations = Set(currentUser.orientations ?? [])
        
        if isAssociationGoal {
            selectedIds = interests.union(concerns).union(orientations)
        } else {
            selectedIds = interests.union(concerns).union(involvements)
        }
    }

    private func loadDTO() {
        tableDTO.removeAll()

        switch self.mode {
        case .involvement:
            AnalyticsLoggerManager.logEvent(name: onboarding_actions_view)
            tableDTO.append(.backArrow)
            tableDTO.append(.title(title: NSLocalizedString("enhanced_onboarding_how_to_act", comment: ""), subtitle: NSLocalizedString("enhanced_onboarding_multiple_options", comment: "")))
            involvementChoices.forEach { tableDTO.append(.fullSizeCell(choice: $0, isSelected: selectedIds.contains($0.id))) }

        case .interest:
            AnalyticsLoggerManager.logEvent(name: onboarding_interests_view)
            tableDTO.append(.backArrow)
            tableDTO.append(.title(title: NSLocalizedString("enhanced_onboarding_my_interests", comment: ""), subtitle: NSLocalizedString("enhanced_onboarding_find_activities", comment: "")))
            tableDTO.append(.collectionViewCell(choices: interestChoices))

        case .concern:
            AnalyticsLoggerManager.logEvent(name: onboarding_donations_categories_view)
            tableDTO.append(.backArrow)
            tableDTO.append(.title(title: NSLocalizedString("enhanced_onboarding_my_concerns", comment: ""), subtitle: NSLocalizedString("enhanced_onboarding_select_concerns", comment: "")))
            concernChoices.forEach { tableDTO.append(.fullSizeCell(choice: $0, isSelected: selectedIds.contains($0.id))) }

        case .choiceDisponibility:
            AnalyticsLoggerManager.logEvent(name: "onboarding_disponibility_view")
            tableDTO.append(.backArrow)
            tableDTO.append(.title(title: NSLocalizedString("enhanced_onboarding_my_availability", comment: ""), subtitle: NSLocalizedString("enhanced_onboarding_select_availability", comment: "")))
            tableDTO.append(.choiceDayCell(days: generateDaysAnd(), selectedDays: selectedDays))
            tableDTO.append(.choiceDayCell(days: generateHours(), selectedDays: selectedHours))

        case .associationPresentation:
            AnalyticsLoggerManager.logEvent(name: "onboarding_association_view")
            tableDTO.append(.backArrow)
            tableDTO.append(.title(title: "Présentez votre association", subtitle: "Ajoutez votre logo et une courte description."))
            
            // Chargement des données si nécessaire
            if associationDescription == nil && associationLogoImage == nil, let pid = currentPartnerId {
                associationPresenter.getPartnerDetails(partnerId: pid)
            }
            
            tableDTO.append(.associationPresentation)
        }
        
        ui_tableview.reloadData()
        
        if hasChangedMod {
            hasChangedMod = false
            ui_tableview.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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

    /// Update User Choices with optional completion handler for custom flow (e.g. going to Asso screen)
    func updateUserChoices(shouldQuit: Bool = true, completion: (() -> Void)? = nil) {
        let interests = interestChoices.filter { selectedIds.contains($0.id) }.map { $0.id }
        let concerns = concernChoices.filter { selectedIds.contains($0.id) }.map { $0.id }
        
        // Séparation logique: Involvements pour user standard, Orientations pour Association
        let selectedInvolvementItems = involvementChoices.filter { selectedIds.contains($0.id) }.map { $0.id }
        let involvements = isAssociationGoal ? [] : selectedInvolvementItems
        let orientations = isAssociationGoal ? selectedInvolvementItems : nil

        UserService.updateUserChoices(interests: interests, concerns: concerns, involvements: involvements, orientations: orientations, selectedDays: self.selectedDays, selectedHours: self.selectedHours) { user, error in
            if let error = error {
                print("Error updating user choices: \(error)")
                // Même en cas d'erreur, on peut vouloir continuer si completion est présent
                if let completion = completion {
                    DispatchQueue.main.async { completion() }
                }
            } else {
                var updatedUser = user ?? UserDefaults.currentUser
                if self.isAssociationGoal, var localUser = updatedUser {
                    // On ne touche pas encore à l'organisation ici, c'est fait dans le presenter Asso
                    UserDefaults.updateCurrentUser(newUser: localUser)
                    updatedUser = localUser
                } else if let _user = updatedUser {
                    UserDefaults.updateCurrentUser(newUser: _user)
                }

                DispatchQueue.main.async {
                    // Si on a un bloc de completion (ex: aller vers écran asso), on l'exécute et on s'arrête là
                    if let completion = completion {
                        completion()
                        return
                    }

                    // Sinon flow normal (Quitter)
                    if self.returnHome {
                        AppState.navigateToMainApp()
                    } else {
                        let config = EnhancedOnboardingConfiguration.shared
                        if config.isInterestsFromSetting {
                            config.isInterestsFromSetting = false
                            self.dismiss(animated: true)
                        } else {
                            OnboardingEndChoicesManager.shared.updateChoices(interests: interests, concerns: concerns, involvements: involvements)
                            self.presentViewControllerWithAnimation(identifier: "enhancedOnboardingEnd")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - TableView Extensions

extension EnhancedViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDTO.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dto = tableDTO[indexPath.row]
        switch dto {
        case .title(let title, let subtitle):
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! EnhancedOnboardingTitle
            cell.configure(title: title, subtitle: subtitle)
            return cell
        case .fullSizeCell(let choice, let isSelected):
            let cell = tableView.dequeueReusableCell(withIdentifier: "fullSizeCell", for: indexPath) as! EnhancedFullSizeCell
            cell.configure(choice: choice, isSelected: isSelected)
            return cell
        case .collectionViewCell(let choices):
            let cell = tableView.dequeueReusableCell(withIdentifier: "collectionViewCell", for: indexPath) as! EnhancedOnboardingCollectionCell
            cell.setItems(choices, selectedIds: selectedIds)
            cell.delegate = self
            return cell
        case .backArrow:
            let cell = tableView.dequeueReusableCell(withIdentifier: "enhancecOnboardingBackCell", for: indexPath) as! EnhancecOnboardingBackCell
            cell.configure(isFromSettings: EnhancedOnboardingConfiguration.shared.isInterestsFromSetting)
            return cell
        case .choiceDayCell(let days, let selectedS):
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChoiceDayCell", for: indexPath) as! ChoiceDayCell
            cell.isDay = days.count >= 5
            cell.selectedDays = selectedS
            cell.configure(days: days)
            cell.delegate = self
            return cell
        case .associationPresentation:
            let cell = tableView.dequeueReusableCell(withIdentifier: "associationPresentationCell", for: indexPath) as! AssociationPresentationCell
            cell.delegate = self
            cell.configure(image: associationLogoImage, description: associationDescription)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableDTO[indexPath.row] {
        case .collectionViewCell:
            return 600
        default:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dto = tableDTO[indexPath.row]
        switch dto {
        case .fullSizeCell(let choice, _):
            if selectedIds.contains(choice.id) { selectedIds.remove(choice.id) }
            else { selectedIds.insert(choice.id) }
            
            tableDTO[indexPath.row] = .fullSizeCell(choice: choice, isSelected: selectedIds.contains(choice.id))
            tableView.reloadRows(at: [indexPath], with: .none)
            
        case .backArrow:
            hasChangedMod = true
            if EnhancedOnboardingConfiguration.shared.isInterestsFromSetting {
                self.dismiss(animated: true) { EnhancedOnboardingConfiguration.shared.isInterestsFromSetting = false }
            } else {
                switch mode {
                case .involvement: presentViewControllerWithAnimation(identifier: "enhancedOnboardingIntro"); return
                case .interest: mode = .involvement
                case .concern: mode = .interest
                case .choiceDisponibility: mode = .concern
                case .associationPresentation: mode = isAssociationGoal ? .interest : .choiceDisponibility
                }
                self.loadDTO()
            }
        default: break
        }
    }
}

// MARK: - Delegates

extension EnhancedViewController: EnhancedOnboardingButtonDelegate {
    func onConfigureLaterClick() { // Bouton Annuler
        self.returnHome = true
        self.updateUserChoices()
    }

    func onNextClick() { // Bouton Valider
        hasChangedMod = true
        if EnhancedOnboardingConfiguration.shared.isInterestsFromSetting { self.updateUserChoices(); return }
        
        switch mode {
        case .involvement:
            mode = .interest
            
        case .interest:
            if isAssociationGoal {
                // CORRECTION: On sauvegarde les infos USER maintenant avant de passer à l'asso
                updateUserChoices(shouldQuit: false) {
                    self.mode = .associationPresentation
                    self.loadDTO()
                }
                return // On return pour ne pas recharger loadDTO deux fois
            } else {
                mode = .concern
            }
            
        case .concern:
            mode = .choiceDisponibility
            
        case .choiceDisponibility:
            self.updateUserChoices()
            return
            
        case .associationPresentation:
            handleAssociationValidation()
            return
        }
        
        self.loadDTO()
    }
    
    // Logique de validation spécifique pour l'association
    private func handleAssociationValidation() {
        guard let pid = currentPartnerId else {
            quitOnboarding()
            return
        }
        
        // On lance la séquence Upload -> Update via le presenter
        associationPresenter.updateUserPartner(partnerId: pid,
                                               newDescription: associationDescription,
                                               newImage: associationLogoImage)
    }
    
    private func quitOnboarding() {
        self.dismiss(animated: true) {
            AppState.navigateToMainApp()
        }
    }
}

extension EnhancedViewController: EnhancedOnboardingCollectionCellDelegate {
    func collectionCell(didSelect choice: OnboardingChoice) {
        if selectedIds.contains(choice.id) { selectedIds.remove(choice.id) }
        else { selectedIds.insert(choice.id) }
        loadDTO()
    }
}

extension EnhancedViewController: ChoiceDayCellDelegate {
    func choiceDayCell(_ cell: ChoiceDayCell, didUpdateSelectedDays selectedDays: Set<Int>, isDay: Bool) {
        if isDay { self.selectedDays = selectedDays }
        else { self.selectedHours = selectedDays }
    }
}

extension EnhancedViewController: AssociationPresentationCellDelegate {
    func associationPresentationCellDidTapUploadLogo(_ cell: AssociationPresentationCell) {
        let p = UIImagePickerController(); p.delegate = self; p.sourceType = .photoLibrary
        present(p, animated: true)
    }
    func associationPresentationCell(_ cell: AssociationPresentationCell, didChangeDescription text: String) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        associationDescription = (t.isEmpty || t.contains("Ex. : Association")) ? nil : t
    }
}

// MARK: - AssociationPresenterDelegate

extension EnhancedViewController: AssociationPresenterDelegate {
    
    func didLoadPartner(_ partner: Partner) {
        // 1. Description
        if self.associationDescription == nil {
            self.associationDescription = partner.descr
        }
        
        // 2. Image Loading
        // PATCH CORRECTION DOUBLE URL :
        // Le backend renvoie parfois : BaseURL + URL_ABSOLUE.
        // On détecte la présence d'une deuxième occurrence de "http" pour extraire la bonne partie.
        
        var urlStr = partner.imageUrl ?? partner.largeLogoUrl ?? partner.smallLogoUrl
        
        if let str = urlStr, let range = str.range(of: "http", options: .backwards) {
            // Si on trouve "http" ailleurs qu'au début (index > 0), c'est une concaténation
            if range.lowerBound != str.startIndex {
                let substring = str[range.lowerBound...]
                // On décode le %3A éventuel (ex: https%3A -> https:)
                urlStr = substring.removingPercentEncoding ?? String(substring)
            }
        }
        
        if self.associationLogoImage == nil, let finalUrl = urlStr {
            if let url = URL(string: finalUrl) {
                print("🔹 DEBUG: Downloading image from \(finalUrl)")
                DispatchQueue.global().async {
                    do {
                        let data = try Data(contentsOf: url)
                        if let img = UIImage(data: data) {
                            DispatchQueue.main.async {
                                if self.associationLogoImage == nil {
                                    self.associationLogoImage = img
                                    // Refresh UI seulement si on est sur l'écran concerné
                                    if self.mode == .associationPresentation {
                                        self.ui_tableview.reloadData()
                                    }
                                }
                            }
                        }
                    } catch {
                        print("Error downloading image: \(error)")
                    }
                }
            }
        }
        
        // 3. Refresh UI pour afficher la description chargée
        if self.mode == .associationPresentation {
            self.ui_tableview.reloadData()
        }
    }
    
    func didUpdatePartnerSuccess() {
        quitOnboarding()
    }
    
    func didFailWithError(_ error: String) {
        let alert = UIAlertController(title: "Erreur", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Helpers

extension EnhancedViewController {
    func generateDaysAnd() -> [String] {
        return [NSLocalizedString("day_monday", comment: ""), NSLocalizedString("day_tuesday", comment: ""), NSLocalizedString("day_wednesday", comment: ""), NSLocalizedString("day_thursday", comment: ""), NSLocalizedString("day_friday", comment: ""), NSLocalizedString("day_saturday", comment: ""), NSLocalizedString("day_sunday", comment: "")]
    }
    func generateHours() -> [String] {
        return [NSLocalizedString("hour_morning", comment: ""), NSLocalizedString("hour_afternoon", comment: ""), NSLocalizedString("hour_evening", comment: "")]
    }
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[.originalImage] as? UIImage { self.associationLogoImage = img; loadDTO() }
        picker.dismiss(animated: true)
    }
}

class EnhancedOnboardingConfiguration {
    static let shared = EnhancedOnboardingConfiguration()
    var isInterestsFromSetting = false
    var isOnboardingFromSetting = false
    var isFromOnboardingFromNormalWay = false
    var shouldSendOnboardingFromNormalWay = false
    var numberOfFilterForEvent = Set<String>()
    var preference: String = ""
    var shouldNotDisplayCampain = false
    private init() {}
}
