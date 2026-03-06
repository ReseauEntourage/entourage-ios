//
//  OnboardingPhase3ViewController.swift
//  entourage
//
//  Created by You on 30/11/2022.
//

import UIKit
import CoreLocation
import GooglePlaces

protocol Phase3fromAppDelegate {
    func updatePreference(userType: UserType)
    func updateLoc(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?)
    func sendOnboardingEnd()
}

enum OnboardingPhase3DTO {
    case titleCell
    case userTypeCell(choice: OnboardingChoice, isSelected: Bool, subtitle: String)
    case assoCell(userIsAsso: Bool)
    case adressCell
}

class OnboardingPhase3ViewController: UIViewController {

    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_next_btn: UIButton!

    weak var pageDelegate: OnboardingDelegate? = nil
    var fromAppDelegate: Phase3fromAppDelegate? = nil

    var location_new: CLLocationCoordinate2D? = nil
    var location_name_new: String? = nil
    var location_googlePlace_new: GMSPlace? = nil

    var isEntour = false
    var isBeEntour = false
    var isBoth = false
    var isAsso = false

    var userTypeSelected = UserType.none
    var tableDTO: [OnboardingPhase3DTO] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        ui_next_btn.addTarget(self, action: #selector(onNextClick), for: .touchUpInside)
        configureOrangeButton(ui_next_btn, withTitle: "next".localized)

        ui_tableview.allowsSelection = true
        ui_tableview.delegate = self
        ui_tableview.dataSource = self

        ui_tableview.register(UINib(nibName: OnboardingPhase3TitleCell.identifier, bundle: nil),
                              forCellReuseIdentifier: OnboardingPhase3TitleCell.identifier)
        ui_tableview.register(UINib(nibName: OnboardingPhase3MapCell.identifier, bundle: nil),
                              forCellReuseIdentifier: OnboardingPhase3MapCell.identifier)
        ui_tableview.register(UINib(nibName: OnboardingPhase3Asso.identifier, bundle: nil),
                              forCellReuseIdentifier: OnboardingPhase3Asso.identifier)
        ui_tableview.register(UINib(nibName: "EnhancedFullSizeCell", bundle: nil),
                              forCellReuseIdentifier: "fullSizeCell")

        loadDTO()
        updateNextState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNextState() // au cas où on revient de la modale de lieu
    }

    // MARK: - DTO
    func loadDTO() {
        tableDTO.removeAll()

        let choice1 = OnboardingChoice(id: "entour",
                                       img: "ic_onboarding_three_entour",
                                       title: NSLocalizedString("onboarding_phase_three_option_entourer", comment: ""))
        let choice2 = OnboardingChoice(id: "been_entour",
                                       img: "ic_onboarding_three_been_entour",
                                       title: NSLocalizedString("onboarding_phase_three_option_etre_entoure", comment: ""))
        let choice3 = OnboardingChoice(id: "both",
                                       img: "ic_onboarding_three_both",
                                       title: NSLocalizedString("onboarding_phase_three_option_les_deux", comment: ""))

        tableDTO.append(.titleCell)
        tableDTO.append(.userTypeCell(choice: choice1,
                                      isSelected: isEntour,
                                      subtitle: "onboarding_phase_three_option_entourer_description".localized))
        tableDTO.append(.userTypeCell(choice: choice2,
                                      isSelected: isBeEntour,
                                      subtitle: "onboarding_phase_three_option_etre_entoure_description".localized))
        // Si vous voulez réactiver "les deux", dé-commentez :
        // tableDTO.append(.userTypeCell(choice: choice3,
        //                               isSelected: isBoth,
        //                               subtitle: "onboarding_phase_three_option_les_deux_description".localized))

        tableDTO.append(.adressCell)
        tableDTO.append(.assoCell(userIsAsso: isAsso))

        ui_tableview.reloadData()
    }

    // MARK: - État du bouton "Suivant"
    private func isFormValid() -> Bool {
        let hasType = isEntour || isBeEntour || isBoth || isAsso
        let hasLoc = (location_new != nil) || (location_googlePlace_new != nil)
        return hasType && hasLoc
    }

    private func updateNextState() {
        let enabled = isFormValid()
        ui_next_btn.isEnabled = enabled
        ui_next_btn.backgroundColor = enabled ? .appOrange : .appOrangeLight
    }

    // MARK: - Tap "Suivant"
    @objc func onNextClick() {
        guard isFormValid() else {
            let alert = UIAlertController(title: nil,
                                          message: "Merci de choisir un profil et une localisation.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        // Propager le type
        updateUserType()

        // Propager la localisation
        if let fromAppDelegate {
            fromAppDelegate.updateLoc(currentlocation: location_new,
                                      currentLocationName: location_name_new,
                                      googlePlace: location_googlePlace_new)
        } else {
            pageDelegate?.addPlace(currentlocation: location_new,
                                   currentLocationName: location_name_new,
                                   googlePlace: location_googlePlace_new)
        }

        // Fin du flux (version AppDelegate)
        dismiss(animated: false) {
            self.fromAppDelegate?.sendOnboardingEnd()
        }
    }

    // MARK: - Style bouton
    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
        // Couleur activée/désactivée gérée dans updateNextState()
    }

    // MARK: - Propagation user type
    func updateUserType() {
        EnhancedOnboardingConfiguration.shared.shouldNotDisplayCampain = true
        if isBeEntour {
            EnhancedOnboardingConfiguration.shared.preference = "contribution"
        }

        var userType: UserType = .none
        if isBeEntour {
            userType = .alone
        } else if isEntour {
            userType = .neighbour
        }
        if isBoth {
            userType = .both
        }
        if isAsso {
            userType = .assos
        }

        if let fromAppDelegate {
            fromAppDelegate.updatePreference(userType: userType)
        } else {
            pageDelegate?.addInfos(userType: userType)
        }

        userTypeSelected = userType
        updateNextState()
    }
}

// MARK: - Table
extension OnboardingPhase3ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDTO.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableDTO[indexPath.row] {
        case .titleCell:
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: OnboardingPhase3TitleCell.identifier) as? OnboardingPhase3TitleCell {
                cell.selectionStyle = .none
                return cell
            }
            return UITableViewCell()

        case .adressCell:
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: OnboardingPhase3MapCell.identifier) as? OnboardingPhase3MapCell {
                cell.selectionStyle = .none
                cell.configure(adress: location_googlePlace_new?.formattedAddress)
                return cell
            }
            return UITableViewCell()

        case .userTypeCell(let choice, let isSelected, let subtitle):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "fullSizeCell", for: indexPath) as? EnhancedFullSizeCell else {
                return UITableViewCell()
            }
            cell.configure(choice: choice, isSelected: isSelected)
            cell.configureAComment(title: choice.title, comment: subtitle)
            cell.selectionStyle = .none
            return cell

        case .assoCell(let userIsAsso):
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: OnboardingPhase3Asso.identifier) as? OnboardingPhase3Asso {
                cell.selectionStyle = .none
                cell.configure(isAsso: userIsAsso)
                return cell
            }
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableDTO[indexPath.row] {
        case .titleCell:
            break

        case .userTypeCell(let choice, _, _):
            switch choice.id {
            case "entour":
                isEntour.toggle()
                isBeEntour = false
                isBoth = false
            case "been_entour":
                isEntour = false
                isBeEntour.toggle()
                isBoth = false
            case "both":
                isBoth.toggle()
                isEntour = false
                isBeEntour = false
            default:
                break
            }
            updateUserType()
            loadDTO()

        case .adressCell:
            let sb = UIStoryboard(name: StoryboardName.profileParams, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "place_choose_vc") as? ParamsChoosePlaceViewController {
                vc.placeVCDelegate = self
                present(vc, animated: true)
            }

        case .assoCell:
            isAsso.toggle()
            updateUserType()
            loadDTO()
        }
    }
}

// MARK: - PlaceViewControllerDelegate
extension OnboardingPhase3ViewController: PlaceViewControllerDelegate {
    func modifyPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        location_new = currentlocation
        location_name_new = currentLocationName
        location_googlePlace_new = googlePlace

        if let fromAppDelegate {
            fromAppDelegate.updateLoc(currentlocation: currentlocation,
                                      currentLocationName: currentLocationName,
                                      googlePlace: googlePlace)
        } else {
            pageDelegate?.addPlace(currentlocation: currentlocation,
                                   currentLocationName: currentLocationName,
                                   googlePlace: googlePlace)
        }

        DispatchQueue.main.async {
            self.loadDTO()
            self.updateNextState()
        }
    }
}
