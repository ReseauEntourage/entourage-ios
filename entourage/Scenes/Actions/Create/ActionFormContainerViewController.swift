//
//  ActionFormContainerViewController.swift
//  entourage
//
//  Conteneur du parcours de création ET de modification d'une entraide (contribution ou demande)
//  (change flux-creation-unifie), en remplacement de `ActionCreateMainViewController` et
//  `ActionEditMainViewController`. L'habillage (progression, pied de page, erreurs, aperçu) est dans
//  `FormFlowContainerViewController` ; ce contrôleur porte les étapes de l'entraide, la liste d'étapes
//  dynamique (l'étape de partage s'ajoute ou se retire), la charte affichée avant l'assistant en création,
//  et l'envoi (création, ou `PUT contributions/{id}` / `solicitations/{id}`).
//
//  Création : `ActionFormContainerViewController()` puis `isContrib` et `parentController`.
//  Modification : renseigner aussi `currentAction`.
//

import UIKit
import SwiftUI
import CoreLocation
import GooglePlaces
import SVProgressHUD

class ActionFormContainerViewController: FormFlowContainerViewController {

    var isContrib: Bool = false
    /// Renseigné en modification.
    var currentAction: Action? = nil

    let formStore = ActionFormStore()
    /// Valeurs de référence : sert à savoir s'il y a des modifications non enregistrées.
    private(set) var initialValues = ActionFormValues()

    var isEditMode: Bool { return currentAction != nil }

    private var charterOverlay: UIView?
    private var charterHost: UIHostingController<ActionCharterView>?

    // MARK: Hooks du conteneur générique -

    private var pages: [ActionFormPage] { return ActionFormSteps.pages(for: formStore.values) }

    override var pageCount: Int { return pages.count }
    override var finalActionTitle: String {
        return (isEditMode ? "action_form_edit_action" : "event_form_publish").localized
    }
    override func quitAlertStrings() -> (title: String, message: String, quit: String, cancel: String) {
        let message = String(format: "actionCreatePopCloseBackMessage".localized, actionTypeName(isContrib: isContrib))
        return ("actionCreatePopCloseBackTitle".localized, message, "actionCreatePopCloseBackQuit".localized, "actionCreatePopCloseBackCancel".localized)
    }

    override func loadInitialState() {
        if let action = currentAction {
            let values = ActionFormValues(action: action)
            formStore.values = values
            initialValues = values
        }
    }

    override func observeValues(_ onChange: @escaping () -> Void) {
        formStore.onValuesChange = onChange
    }

    override func hasUnsavedChanges() -> Bool { return formStore.values != initialValues }

    private func step(at index: Int) -> ActionCreateStep? {
        let pages = self.pages
        guard index >= 0, index < pages.count, case .step(let step) = pages[index] else { return nil }
        return step
    }

    private func validationContext() -> ActionFormValidationContext {
        var context = ActionFormValidationContext()
        context.isEdit = isEditMode
        context.initialHadPlace = initialValues.hasPlace
        context.initialHadSection = initialValues.sectionKey != nil
        return context
    }

    override func isStepValid(at index: Int) -> Bool {
        guard let step = step(at: index) else { return true }
        return ActionFormValidator.errors(for: step, values: formStore.values, context: validationContext()).isEmpty
    }

    override func displayErrors(forStepAt index: Int?) {
        if let index = index, let step = step(at: index) {
            formStore.errors = ActionFormValidator.errors(for: step, values: formStore.values, context: validationContext())
        }
        else {
            formStore.errors = [:]
        }
    }

    /// Le cache d'écrans est indexé par page (et non par position) : l'étape de partage peut disparaître.
    override func pageIdentifier(at index: Int) -> AnyHashable {
        let pages = self.pages
        return pages[min(max(index, 0), pages.count - 1)]
    }

    override func makePage(at index: Int) -> UIViewController? {
        let pages = self.pages
        switch pages[min(max(index, 0), pages.count - 1)] {
        case .preview:
            return FormFlowHostViewController(ActionPreviewView(store: formStore, isContrib: isContrib))
        case .step(.category):
            let sections = (Metadatas.sharedInstance.tagsSections?.getSections() ?? []).map {
                (key: $0.key, subtitle: $0.subtitle, imageName: $0.getImageName())
            }
            return FormFlowHostViewController(ActionStepCategoryView(store: formStore, isContrib: isContrib, sections: sections))
        case .step(.details):
            return FormFlowHostViewController(ActionStepDetailsView(store: formStore, isContrib: isContrib, onPickImage: { [weak self] in self?.showPickImage() }))
        case .step(.location):
            return FormFlowHostViewController(ActionStepLocationView(store: formStore, isContrib: isContrib, onPickPlace: { [weak self] in self?.showPlacePicker() }))
        case .step(.share):
            return FormFlowHostViewController(ActionStepShareView(store: formStore, isContrib: isContrib))
        }
    }

    override func pageDidShow(at index: Int) {
        guard !isEditMode, let step = step(at: index) else { return }
        switch step {
        case .category: AnalyticsLoggerManager.logEvent(name: isContrib ? Help_create_contrib_1 : Help_create_demand_1)
        case .details: AnalyticsLoggerManager.logEvent(name: isContrib ? Help_create_contrib_2 : Help_create_demand_2)
        case .location: AnalyticsLoggerManager.logEvent(name: isContrib ? Help_create_contrib_3 : Help_create_demand_3)
        case .share: break
        }
    }

    // MARK: Cycle de vie -

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDefaultGroup()
        if !isEditMode {
            showCharter()
        }
    }

    private func fetchDefaultGroup() {
        NeighborhoodService.getDefaultGroup { [weak self] group, _ in
            if let group = group {
                self?.formStore.defaultGroupName = group.name
            }
        }
    }

    // MARK: Charte (création) -

    /// La charte reste affichée avant l'assistant en création : elle recouvre l'écran jusqu'à validation.
    private func showCharter() {
        AnalyticsLoggerManager.logEvent(name: isContrib ? Help_create_contrib_chart : Help_create_demand_chart)

        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = .white
        view.addSubview(overlay)

        let backButton = UIButton(type: .custom)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = FormFlowStyle.uiInk
        backButton.layer.cornerRadius = 16.5
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor(red: 221 / 255, green: 221 / 255, blue: 221 / 255, alpha: 1).cgColor
        backButton.accessibilityLabel = "event_form_back".localized
        backButton.addTarget(self, action: #selector(charterBackTapped), for: .touchUpInside)
        overlay.addSubview(backButton)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "action_charter_screen_title".localized
        titleLabel.font = ApplicationTheme.getFontQuickSandBold(size: 20)
        titleLabel.textColor = FormFlowStyle.uiInk
        overlay.addSubview(titleLabel)

        let charterView = ActionCharterView(isContrib: isContrib, onAccept: { [weak self] in
            self?.acceptCharter()
        }, onReadFullCharter: { [weak self] in
            self?.showFullCharter()
        })
        let host = UIHostingController(rootView: charterView)
        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.backgroundColor = .clear
        overlay.addSubview(host.view)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            backButton.topAnchor.constraint(equalTo: safe.topAnchor, constant: 15),
            backButton.leadingAnchor.constraint(equalTo: overlay.leadingAnchor, constant: 18),
            backButton.widthAnchor.constraint(equalToConstant: 33),
            backButton.heightAnchor.constraint(equalToConstant: 33),

            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: overlay.trailingAnchor, constant: -22),

            host.view.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 12),
            host.view.leadingAnchor.constraint(equalTo: overlay.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: overlay.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: overlay.bottomAnchor)
        ])
        host.didMove(toParent: self)
        charterOverlay = overlay
        charterHost = host
    }

    @objc private func charterBackTapped() {
        // Aucune saisie à ce stade : on quitte directement.
        dismiss(animated: true)
    }

    private func acceptCharter() {
        guard let overlay = charterOverlay else { return }
        charterHost?.willMove(toParent: nil)
        overlay.removeFromSuperview()
        charterHost?.removeFromParent()
        charterOverlay = nil
        charterHost = nil
    }

    private func showFullCharter() {
        if let vc = UIStoryboard(name: StoryboardName.actions, bundle: nil).instantiateViewController(withIdentifier: "params_CGU_VC") as? ActionParamsCGUViewController {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }

    // MARK: Sélecteurs (lieu, image) -

    private func showPlacePicker() {
        let sb = UIStoryboard(name: StoryboardName.profileParams, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "place_choose_vc") as? ParamsChoosePlaceViewController {
            vc.placeVCDelegate = self
            vc.isFromActions = true
            vc.isContrib = isContrib
            present(vc, animated: true)
        }
    }

    private func showPickImage() {
        let sb = UIStoryboard(name: StoryboardName.actionCreate, bundle: nil)
        if let navvc = sb.instantiateViewController(withIdentifier: "addPhotoNav") as? UINavigationController,
           let vc = navvc.topViewController as? ActionAddPhotoViewController {
            vc.parentDelegate = self
            present(navvc, animated: true)
        }
    }

    // MARK: Réseau -

    override func publish() {
        if isEditMode {
            updateAction()
        }
        else {
            createAction()
        }
    }

    /// Partage dans un groupe : demandé uniquement quand l'étape de partage est dans la liste.
    private var autoPost: Bool {
        return formStore.values.hasShareStep ? (formStore.values.shareToGroup ?? false) : false
    }

    private func createAction() {
        let action = formStore.values.makeAction()
        let autoPost = self.autoPost
        SVProgressHUD.show()
        ActionCreateStateManager.shared.clearSection()

        let completion: (Action?) -> Void = { [weak self] created in
            SVProgressHUD.dismiss()
            if let created = created {
                self?.goEnd(action: created)
            }
            else {
                self?.showError()
            }
        }

        if isContrib, let image = formStore.localImage {
            ContribUploadPictureService.prepareUploadWith(image: image, action: action, isUpdate: false, autoPost: autoPost) { created, _ in
                completion(created)
            }
        }
        else {
            ActionsService.createAction(isContrib: isContrib, action: action, autoPost: autoPost) { created, _ in
                completion(created)
            }
        }
    }

    private func updateAction() {
        guard let current = currentAction else { return }
        var action = formStore.values.makeEditing(from: current)
        action.id = current.id
        let autoPost = self.autoPost
        SVProgressHUD.show()

        let completion: (Action?) -> Void = { [weak self] updated in
            SVProgressHUD.dismiss()
            if updated != nil {
                self?.goEndEdit()
            }
            else {
                self?.showError()
            }
        }

        if isContrib, let image = formStore.localImage {
            ContribUploadPictureService.prepareUploadWith(image: image, action: action, isUpdate: true, autoPost: autoPost) { updated, _ in
                completion(updated)
            }
        }
        else {
            ActionsService.updateAction(isContrib: isContrib, action: action, autoPost: autoPost) { updated, _ in
                completion(updated)
            }
        }
    }

    private func showError() {
        let type = isContrib ? "action_contrib".localized : "action_solicitation".localized
        SVProgressHUD.show(withStatus: String(format: "action_form_save_error".localized, type))
    }

    private func goEnd(action: Action) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationActionCreateEnd), object: nil)
        let sb = UIStoryboard(name: StoryboardName.actionCreate, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "action_validateVC") as? ActionCreateValidateViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.actionId = action.id
            vc.isContrib = isContrib
            AnalyticsLoggerManager.logEvent(name: isContrib ? Help_create_contrib_end : Help_create_demand_end)
            let parent = parentController
            dismiss(animated: false) {
                parent?.present(vc, animated: true)
            }
        }
    }

    private func goEndEdit() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationActionUpdate), object: nil)
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
}

// MARK: - PlaceViewControllerDelegate -
extension ActionFormContainerViewController: PlaceViewControllerDelegate {
    func modifyPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        if let currentlocation = currentlocation {
            formStore.setPlace(name: currentLocationName ?? "", latitude: currentlocation.latitude, longitude: currentlocation.longitude)
        }
        else if let googlePlace = googlePlace {
            formStore.setPlace(name: googlePlace.formattedAddress ?? googlePlace.name ?? "", latitude: googlePlace.coordinate.latitude, longitude: googlePlace.coordinate.longitude)
        }
    }
}

// MARK: - TakePhotoDelegate -
extension ActionFormContainerViewController: TakePhotoDelegate {
    func updatePhoto(image: UIImage?) {
        formStore.setImage(image)
    }
}

// MARK: - Section mémorisée pour les placeholders -

/// Section choisie, mémorisée pour les écrans qui en dépendent (placeholders, détail d'une entraide).
class ActionCreateStateManager {
    static let shared = ActionCreateStateManager()

    var selectedSectionKey: String?
    var isContrib: Bool = false // Détermine si c'est une contribution ou une demande

    func storeSection(_ section: String, isContrib: Bool) {
        UserDefaults.standard.set(section, forKey: "selectedSection")
        self.isContrib = isContrib
    }

    func getSection() -> String? {
        return UserDefaults.standard.string(forKey: "selectedSection")
    }

    func clearSection() {
        UserDefaults.standard.removeObject(forKey: "selectedSection")
    }
}
