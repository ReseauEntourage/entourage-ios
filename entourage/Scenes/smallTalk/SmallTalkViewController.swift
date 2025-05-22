//
//  SmallTalkViewController.swift
//  SmallTalk
//
//  Created by ChatGPT on 19/05/2025.
//

import UIKit

// MARK: - Modèles
struct SmallTalkChoice: Hashable {
    let id: String
    let title: String
    let subtitle: String?
    let imageName: String
}

struct SmallTalkStep {
    let title: String
    let subtitle: String
    let choices: [SmallTalkChoice]
    let allowsMultipleSelection: Bool
}

/// Lignes de table
private enum Row {
    case fullSize(SmallTalkChoice)
    case grid([SmallTalkChoice])
}

// MARK: - ViewController
final class SmallTalkViewController: UIViewController {

    // Outlets storyboard
    @IBOutlet private weak var ui_progress: UIProgressView!
    @IBOutlet private weak var ui_titleLabel: UILabel!
    @IBOutlet private weak var ui_subtitleLabel: UILabel!
    @IBOutlet private weak var ui_tableView: UITableView!
    @IBOutlet private weak var ui_btn_previous: UIButton!
    @IBOutlet private weak var ui_btn_next: UIButton!

    // Données
    private var steps: [SmallTalkStep] = []
    private var userRequest:UserSmallTalkRequest?
    private var currentStepIndex = 0 {
        didSet { rebuildRows(animated: true) }
    }
    private var selectedIdsByStep: [Int: Set<String>] = [:]
    private var rows: [Row] = []
    

    // MARK: Life-cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSteps()

        // Pré-remplir les intérêts de l'utilisateur pour l'étape 5
        if let interests = UserDefaults.currentUser?.interests, !interests.isEmpty {
            selectedIdsByStep[4] = Set(interests)
        }

        configureTable()
        configureOrangeButton(ui_btn_next, withTitle: "action_create_group_bt_next".localized)
        configureOrangeButton(ui_btn_previous, withTitle: "previous".localized)
        rebuildRows(animated: false)
        
        ui_titleLabel.setFontTitle(size: 18)
        ui_subtitleLabel.setFontBody(size: 15)
        
        ui_btn_next.addTarget(self, action: #selector(goToNext), for: .touchUpInside)
        ui_btn_previous.addTarget(self, action: #selector(goToPrevious), for: .touchUpInside)
        
        ui_progress.progressTintColor = UIColor(red: 0.67, green: 0.87, blue: 0.64, alpha: 1.0) // proche de #ACDFA3
        ui_progress.trackTintColor = UIColor(white: 0.9, alpha: 1.0)
    }

    
    func configure(with request: UserSmallTalkRequest) {
        self.userRequest = request
    }
}

// MARK: - Configuration
private extension SmallTalkViewController {
    func configureSteps() {
        steps = [
            // Étape 1 : Format
            SmallTalkStep(
                title: NSLocalizedString("small_talk_step_title_1", comment: ""),
                subtitle: NSLocalizedString("small_talk_step_subtitle_1", comment: ""),
                choices: [
                    SmallTalkChoice(id: "one",
                                    title: NSLocalizedString("small_talk_step1_item1_title", comment: ""),
                                    subtitle: NSLocalizedString("small_talk_step1_item1_subtitle", comment: ""),
                                    imageName: "ic_duo"),
                    SmallTalkChoice(id: "many",
                                    title: NSLocalizedString("small_talk_step1_item2_title", comment: ""),
                                    subtitle: NSLocalizedString("small_talk_step1_item2_subtitle", comment: ""),
                                    imageName: "ic_quator")
                ],
                allowsMultipleSelection: false),

            // Étape 2 : Proximité
            SmallTalkStep(
                title: NSLocalizedString("small_talk_step_title_2", comment: ""),
                subtitle: NSLocalizedString("small_talk_step_subtitle_2", comment: ""),
                choices: [
                    SmallTalkChoice(id: "local",
                                    title: NSLocalizedString("small_talk_step2_item1_title", comment: ""),
                                    subtitle: NSLocalizedString("small_talk_step2_item1_subtitle", comment: ""),
                                    imageName: "ic_local"),
                    SmallTalkChoice(id: "france",
                                    title: NSLocalizedString("small_talk_step2_item2_title", comment: ""),
                                    subtitle: NSLocalizedString("small_talk_step2_item2_subtitle", comment: ""),
                                    imageName: "ic_global")
                ],
                allowsMultipleSelection: false),

            // Étape 3 : Genre
            SmallTalkStep(
                title: NSLocalizedString("small_talk_step_title_3", comment: ""),
                subtitle: NSLocalizedString("small_talk_step_subtitle_3", comment: ""),
                choices: [
                    SmallTalkChoice(id: "male", // ⬅️ adapté au backend
                                    title: NSLocalizedString("small_talk_step3_item1_title", comment: ""),
                                    subtitle: nil,
                                    imageName: ""),
                    SmallTalkChoice(id: "female",
                                    title: NSLocalizedString("small_talk_step3_item2_title", comment: ""),
                                    subtitle: nil,
                                    imageName: ""),
                    SmallTalkChoice(id: "non_binary",
                                    title: NSLocalizedString("small_talk_step3_item3_title", comment: ""),
                                    subtitle: nil,
                                    imageName: "")
                ],
                allowsMultipleSelection: false),


            // Étape 4 : Confort
            SmallTalkStep(
                title: NSLocalizedString("small_talk_step_title_4", comment: ""),
                subtitle: NSLocalizedString("small_talk_step_subtitle_4", comment: ""),
                choices: [
                    SmallTalkChoice(id: "all",
                                    title: NSLocalizedString("small_talk_step4_item1_title", comment: ""),
                                    subtitle: NSLocalizedString("small_talk_step4_item1_subtitle", comment: ""),
                                    imageName: ""),
                    SmallTalkChoice(id: "same",
                                    title: NSLocalizedString("small_talk_step4_item2_title", comment: ""),
                                    subtitle: NSLocalizedString("small_talk_step4_item2_subtitle", comment: ""),
                                    imageName: "")
                ],
                allowsMultipleSelection: false),

            // Étape 5 : Intérêts
            SmallTalkStep(
                title: NSLocalizedString("small_talk_step_interest_title", comment: ""),
                subtitle: NSLocalizedString("small_talk_step_interest_subtitle", comment: ""),
                choices: loadInterests(),
                allowsMultipleSelection: true)
        ]
    }
    
    

    func configureTable() {
        ui_tableView.dataSource = self
        ui_tableView.delegate   = self
        ui_tableView.separatorStyle = .none

        ui_tableView.register(UINib(nibName: "EnhancedFullSizeCell", bundle: nil),
                              forCellReuseIdentifier: "fullSizeCell")
        ui_tableView.register(UINib(nibName: "EnhancedOnboardingCollectionCell", bundle: nil),
                              forCellReuseIdentifier: "collectionViewCell")
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
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }
}

// MARK: - Construction UI
private extension SmallTalkViewController {

    func rebuildRows(animated: Bool) {
        rows.removeAll()
        let step = steps[currentStepIndex]

        // Titre / sous-titre
        ui_titleLabel.text    = step.title
        ui_subtitleLabel.text = step.subtitle

        // Rows
        if step.allowsMultipleSelection {
            rows.append(.grid(step.choices))
        } else {
            rows.append(contentsOf: step.choices.map { .fullSize($0) })
        }

        // Progression
        let progress = Float(currentStepIndex + 1) / Float(steps.count + 1)
        animated ? ui_progress.setProgress(progress, animated: true)
                 : (ui_progress.progress = progress)

        ui_tableView.reloadData()
        updateNavButtons()
    }

    func updateNavButtons() {
        ui_btn_previous.isEnabled = currentStepIndex > 0

        let isLastStep = currentStepIndex == steps.count - 1
        let hasSelection = !(selectedIdsByStep[currentStepIndex]?.isEmpty ?? true)
                           || steps[currentStepIndex].allowsMultipleSelection
        ui_btn_next.isEnabled = hasSelection
        ui_btn_next.setTitle(isLastStep
                             ? "action_create_close_button".localized
                             : "enhanced_onboarding_button_title_next".localized,
                             for: .normal)
    }
}

// MARK: - Sélection & navigation
private extension SmallTalkViewController {
    func advanceOrShowError(_ updated: UserSmallTalkRequest?, _ error: EntourageNetworkError?) {
        DispatchQueue.main.async {
            if let error = error {
                print("❌ Erreur update : )" , error.message)
                let alert = UIAlertController(title: "Erreur", message: "Une erreur est survenue", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                return
            }

            if let updated = updated {
                self.userRequest = updated
            }

            let isLast = self.currentStepIndex == self.steps.count - 1
            if isLast {
                print("🎯 Fin du flow")
                let sb = UIStoryboard(name: StoryboardName.profileParams, bundle: nil)
                if let navVC = sb.instantiateViewController(withIdentifier: "editProfilePhotoNav") as? UINavigationController,
                   let editPhotoVC = navVC.topViewController as? UserPhotoAddViewController {

                    // Passer la request à la vue suivante si nécessaire
                    editPhotoVC.pictureSettingDelegate = self as? ImageReUpLoadDelegate
                    editPhotoVC.isSmallTalkMode = true
                    editPhotoVC.userRequest = self.userRequest
                    navVC.modalPresentationStyle = .fullScreen // ⬅️ AJOUT ICI
                    self.present(navVC, animated: true)
                }
                return
            } else {
                self.currentStepIndex += 1
                self.rebuildRows(animated: true)
            }
        }
    }
    

    func toggle(id: String) {
        var set = selectedIdsByStep[currentStepIndex, default: []]
        if steps[currentStepIndex].allowsMultipleSelection {
            set.toggleMembership(of: id)
        } else {
            set = [id]
        }
        selectedIdsByStep[currentStepIndex] = set
        updateNavButtons()
    }

    @objc func goToPrevious() {
        guard currentStepIndex > 0 else { return }
        currentStepIndex -= 1
        rebuildRows(animated: true)
        if(currentStepIndex == 0){
            self.dismiss(animated: true) {
                
            }
        }else{
            print("eho current step ", currentStepIndex)
        }
    }

    @objc func goToNext() {
        guard let selected = selectedIdsByStep[currentStepIndex], !selected.isEmpty else { return }
        guard let userRequestId = userRequest?.uuid_v2 else {
            let alert = UIAlertController(title: "Erreur", message: "Identifiant de la demande introuvable.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        switch currentStepIndex {
        case 0:
            // match_format : "one" ou "many"
            let field = UserSmallTalkFields(match_format: selected.first, match_locality: nil, match_gender: nil, user_gender: nil)
            SmallTalkService.updateUserSmallTalkRequest(id: userRequestId, fields: field) { [weak self] updated, error in
                self?.advanceOrShowError(updated, error)
            }

        case 1:
            // match_locality : Bool
            let isLocal = selected.contains("local")
            let field = UserSmallTalkFields(match_format: nil, match_locality: isLocal, match_gender: nil, user_gender: nil)
            SmallTalkService.updateUserSmallTalkRequest(id: userRequestId, fields: field) { [weak self] updated, error in
                self?.advanceOrShowError(updated, error)
            }

        case 2:
            // user_gender → via UserService
            if let gender = selected.first {
                var updatedUser = UserDefaults.currentUser
                updatedUser?.gender = gender
                UserService.updateUser(user: updatedUser) { [weak self] _, error in
                    self?.advanceOrShowError(nil, error)
                }
            }

        case 3:
            // match_gender : Bool
            let isSame = selected.contains("same")
            let field = UserSmallTalkFields(match_format: nil, match_locality: nil, match_gender: isSame, user_gender: nil)
            SmallTalkService.updateUserSmallTalkRequest(id: userRequestId, fields: field) { [weak self] updated, error in
                self?.advanceOrShowError(updated, error)
            }

        case 4:
            // intérêts → UserService
            let interests = Array(selected)
            UserService.updateUserInterests(interests: interests) { [weak self] _, error in
                self?.advanceOrShowError(nil, error)
            }

        default:
            break
        }
    }

}



// MARK: - TableView
extension SmallTalkViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int { rows.count }

    func tableView(_ tv: UITableView, cellForRowAt idx: IndexPath) -> UITableViewCell {
        switch rows[idx.row] {
        case let .fullSize(choice):
            let cell = tv.dequeueReusableCell(withIdentifier: "fullSizeCell", for: idx) as! EnhancedFullSizeCell
            let ob = OnboardingChoice(id: choice.id, img: choice.imageName, title: choice.title)
            cell.configure(choice: ob, isSelected: isSelected(id: choice.id))
            return cell

        case let .grid(choices):
            let cell = tv.dequeueReusableCell(withIdentifier: "collectionViewCell", for: idx) as! EnhancedOnboardingCollectionCell
            let obChoices = choices.map { OnboardingChoice(id: $0.id, img: $0.imageName, title: $0.title) }
            cell.setItems(obChoices, selectedIds: selectedIdsByStep[currentStepIndex] ?? [])
            cell.delegate = self
            return cell
        }
    }

    func tableView(_ tv: UITableView, didSelectRowAt idx: IndexPath) {
        switch rows[idx.row] {
        case let .fullSize(choice):
            toggle(id: choice.id)
            tv.reloadData()

        case .grid:
            break // handled by collection delegate
        }
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if case .grid = rows[indexPath.row] { return 900 }
        return UITableView.automaticDimension
    }
}

// MARK: - Collection delegate
extension SmallTalkViewController: EnhancedOnboardingCollectionCellDelegate {
    func collectionCell(didSelect choice: OnboardingChoice) {
        toggle(id: choice.id)
        rebuildRows(animated: false)
    }
}

// MARK: - Helpers
private extension SmallTalkViewController {

    func isSelected(id: String) -> Bool {
        selectedIdsByStep[currentStepIndex]?.contains(id) ?? false
    }

    func loadInterests() -> [SmallTalkChoice] {
        return [
            SmallTalkChoice(id: "sport",
                            title: NSLocalizedString("enhanced_onboarding_interest_sport", comment: ""),
                            subtitle: nil,
                            imageName: "interest_sport"),
            SmallTalkChoice(id: "animaux",
                            title: NSLocalizedString("enhanced_onboarding_interest_animals", comment: ""),
                            subtitle: nil,
                            imageName: "interest_animaux"),
            SmallTalkChoice(id: "marauding",
                            title: NSLocalizedString("enhanced_onboarding_interest_social_marauding", comment: ""),
                            subtitle: nil,
                            imageName: "interest_rencontre-nomade"),
            SmallTalkChoice(id: "cuisine",
                            title: NSLocalizedString("enhanced_onboarding_interest_cooking", comment: ""),
                            subtitle: nil,
                            imageName: "interest_cuisine"),
            SmallTalkChoice(id: "jeux",
                            title: NSLocalizedString("enhanced_onboarding_interest_games", comment: ""),
                            subtitle: nil,
                            imageName: "interest_jeux"),
            SmallTalkChoice(id: "activites",
                            title: NSLocalizedString("enhanced_onboarding_interest_manual_activities", comment: ""),
                            subtitle: nil,
                            imageName: "interest_activite-manuelle"),
            SmallTalkChoice(id: "bien-etre",
                            title: NSLocalizedString("enhanced_onboarding_interest_wellbeing", comment: ""),
                            subtitle: nil,
                            imageName: "interest_bien-etre"),
            SmallTalkChoice(id: "nature",
                            title: NSLocalizedString("enhanced_onboarding_interest_nature", comment: ""),
                            subtitle: nil,
                            imageName: "interest_nature"),
            SmallTalkChoice(id: "culture",
                            title: NSLocalizedString("enhanced_onboarding_interest_art_culture", comment: ""),
                            subtitle: nil,
                            imageName: "interest_art"),
            SmallTalkChoice(id: "other",
                            title: NSLocalizedString("enhanced_onboarding_interest_other", comment: ""),
                            subtitle: nil,
                            imageName: "interest_autre")
        ]
    }
}

private extension Set where Element: Hashable {
    mutating func toggleMembership(of member: Element) {
        if contains(member) {
            remove(member)          // ignore la valeur retournée (Element?)
        } else {
            insert(member)          // ignore le tuple retourné
        }
    }
}
