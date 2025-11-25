//
//  OnboardingPhase3ViewController.swift
//  entourage
//
//  Remplace l’ancienne implémentation :
//  - plus de bloc “adresse”/carte ici
//  - bouton “Suivant” activé dès qu’un type est choisi
//  - UI basée sur EnhancedFullSizeCell
//

import UIKit
import CoreLocation
import GooglePlaces

enum OnboardingPhase3Row {
    case title
    case userType(choice: OnboardingChoice, isSelected: Bool, subtitle: String)
}

final class OnboardingPhase3ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var ui_tableview: UITableView!
    @IBOutlet private weak var ui_next_btn: UIButton!

    // MARK: - Wiring
    weak var pageDelegate: OnboardingDelegate?

    // MARK: - State
    private var rows: [OnboardingPhase3Row] = []

    private var isEntour = false
    private var isBeEntour = false
    private var isAsso = false

    private(set) var userTypeSelected: UserType = .none

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cells
        ui_tableview.register(UINib(nibName: OnboardingPhase3TitleCell.identifier, bundle: nil),
                              forCellReuseIdentifier: OnboardingPhase3TitleCell.identifier)
        ui_tableview.register(UINib(nibName: "EnhancedFullSizeCell", bundle: nil),
                              forCellReuseIdentifier: "fullSizeCell")

        ui_tableview.delegate = self
        ui_tableview.dataSource = self
        ui_tableview.allowsSelection = true

        ui_next_btn.addTarget(self, action: #selector(onNext), for: .touchUpInside)
        configureOrange(button: ui_next_btn, title: "next".localized)
        updateNextButton()

        // Alignement avec Android : on désactive la campagne dès qu’on arrive sur cette phase
        EnhancedOnboardingConfiguration.shared.shouldNotDisplayCampain = true
        AnalyticsLoggerManager.logEvent(name: Onboard_profile)

        rebuildRows()
    }

    // MARK: - UI helpers
    private func configureOrange(button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }

    private func updateNextButton() {
        let enabled = (userTypeSelected != .none)
        ui_next_btn.isEnabled = enabled
        ui_next_btn.backgroundColor = enabled ? .appOrange : .appOrangeLight
    }

    private func rebuildRows() {
        rows.removeAll()

        // Titre
        rows.append(.title)

        // ⚙️ Choix — alignés avec Android :
        //
        // Android :
        // - BE_ENTOUR   -> option_surround / option_surround_desc / ic_been_entoured_onboarding
        // - ENTOUR      -> option_supported / option_supported_desc / onboarding_entour
        // - ASSO        -> onboard_phase3_asso_title / onboard_phase3_asso_desc / onboarding_asso

        let choiceBeEntour = OnboardingChoice(
            id: "been_entour",
            img: "ic_role_been_entour",
            title: NSLocalizedString("onboarding_phase_three_option_etre_entoure", comment: "")
        )

        let choiceEntour = OnboardingChoice(
            id: "entour",
            img: "ic_role_entour",
            title: NSLocalizedString("onboarding_phase_three_option_entourer", comment: "")
        )

        let choiceAsso = OnboardingChoice(
            id: "asso",
            img: "ic_role_asso", // même nom logique que sur Android
            title: NSLocalizedString("onboard_phase3_asso_title", comment: "")
        )

        rows.append(.userType(
            choice: choiceBeEntour,
            isSelected: isBeEntour,
            subtitle: "onboarding_phase_three_option_etre_entoure_description".localized)
        )

        rows.append(.userType(
            choice: choiceEntour,
            isSelected: isEntour,
            subtitle: "onboarding_phase_three_option_entourer_description".localized)
        )

        rows.append(.userType(
            choice: choiceAsso,
            isSelected: isAsso,
            subtitle: "onboard_phase3_asso_desc".localized)
        )

        ui_tableview.reloadData()
    }

    // MARK: - Selection logic
    private func applySelection(choiceId: String) {
        // 👉 Comportement Android : un seul choix sélectionné à la fois
        switch choiceId {
        case "entour":
            isEntour = true
            isBeEntour = false
            isAsso = false
        case "been_entour":
            isEntour = false
            isBeEntour = true
            isAsso = false
        case "asso":
            isEntour = false
            isBeEntour = false
            isAsso = true
        default:
            break
        }

        propagateUserType()
        rebuildRows()
    }

    private func propagateUserType() {
        EnhancedOnboardingConfiguration.shared.shouldNotDisplayCampain = true
        if isBeEntour {
            // Même logique qu’avant : être entouré -> contribution
            EnhancedOnboardingConfiguration.shared.preference = "contribution"
        }

        var userType: UserType = .none
        if isBeEntour { userType = .alone }
        else if isEntour { userType = .neighbour }
        if isAsso { userType = .assos }

        userTypeSelected = userType
        pageDelegate?.addInfos(userType: userType)
        updateNextButton()
    }

    // MARK: - Actions
    @objc private func onNext() {
        // Ici, aucune localisation – on laisse OnboardingStart pousser la vue ZoneChoice ensuite
        dismissKeyboard()
        // Rien d’autre à faire : OnboardingStartViewController gère le “Next” global
    }

    private func dismissKeyboard() { view.endEditing(true) }
}

// MARK: - Table
extension OnboardingPhase3ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch rows[indexPath.row] {
        case .title:
            let cell = tableView.dequeueReusableCell(withIdentifier: OnboardingPhase3TitleCell.identifier, for: indexPath) as! OnboardingPhase3TitleCell
            cell.selectionStyle = .none
            return cell

        case .userType(let choice, let isSelected, let subtitle):
            let cell = tableView.dequeueReusableCell(withIdentifier: "fullSizeCell", for: indexPath) as! EnhancedFullSizeCell
            cell.selectionStyle = .none
            cell.configure(choice: choice, isSelected: isSelected) { subtitle }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch rows[indexPath.row] {
        case .userType(let choice, _, _):
            applySelection(choiceId: choice.id)
        case .title:
            break
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch rows[indexPath.row] {
        case .title: return UITableView.automaticDimension
        case .userType: return UITableView.automaticDimension
        }
    }
}

protocol Phase3fromAppDelegate: AnyObject {

    /// Affiche l’écran de fin d’onboarding.
    func sendOnboardingEnd()

    /// Met à jour la préférence / le type d’utilisateur choisi à la phase 3.
    func updatePreference(userType: UserType)

    /// Met à jour l’adresse de l’utilisateur choisie pendant l’onboarding.
    func updateLoc(
        currentlocation: CLLocationCoordinate2D?,
        currentLocationName: String?,
        googlePlace: GMSPlace?
    )
}
