//
//  GroupFormContainerViewController.swift
//  entourage
//
//  Conteneur du parcours de création ET de modification d'un groupe (change flux-creation-unifie),
//  en remplacement de `NeighborhoodCreateMainViewController` et `NeighborhoodEditViewController`.
//  L'habillage (progression, pied de page, erreurs, aperçu) est dans `FormFlowContainerViewController` ;
//  ce contrôleur porte les étapes du groupe, l'envoi (`POST neighborhoods` ou `PATCH neighborhoods/{id}`)
//  et les textes de sortie.
//
//  Création : `GroupFormContainerViewController()` puis `parentController`.
//  Modification : renseigner `neighborhoodId` (et `currentNeighborhood` si déjà connu).
//

import UIKit
import CoreLocation
import GooglePlaces
import SVProgressHUD

class GroupFormContainerViewController: FormFlowContainerViewController {

    /// Renseigné en modification.
    var neighborhoodId: Int? = nil
    var currentNeighborhood: Neighborhood? = nil
    weak var parentDelegate: UserProfileDetailDelegate? = nil

    let formStore = GroupFormStore()
    /// Valeurs de référence : sert à savoir s'il y a des modifications non enregistrées.
    private(set) var initialValues = GroupFormValues()

    var isEditMode: Bool { return neighborhoodId != nil }

    // MARK: Hooks du conteneur générique -

    override var pageCount: Int { return GroupFormPage.count }
    override var finalActionTitle: String {
        return (isEditMode ? "group_form_edit_action" : "neighborhood_create_group_bt_create").localized
    }
    override var quitAlertKeys: (title: String, message: String, quit: String, cancel: String) {
        let message = isEditMode ? "group_form_edit_quit_message" : "neighborhoodCreatePopCloseBackMessage"
        return ("neighborhoodCreatePopCloseBackTitle", message, "neighborhoodCreatePopCloseBackQuit", "neighborhoodCreatePopCloseBackCancel")
    }

    override func loadInitialState() {
        if let group = currentNeighborhood {
            let values = GroupFormValues(neighborhood: group)
            formStore.values = values
            initialValues = values
        }
    }

    override func observeValues(_ onChange: @escaping () -> Void) {
        formStore.onValuesChange = onChange
    }

    override func hasUnsavedChanges() -> Bool { return formStore.values != initialValues }

    private func step(at index: Int) -> GroupCreateStep? {
        guard index >= 0, index < GroupFormPage.count, case .step(let step) = GroupFormPage.all[index] else { return nil }
        return step
    }

    private func validationContext() -> GroupFormValidationContext {
        var context = GroupFormValidationContext()
        context.isEdit = isEditMode
        context.initialHadPlace = initialValues.hasPlace
        context.initialHadPhoto = initialValues.hasPhoto
        return context
    }

    override func isStepValid(at index: Int) -> Bool {
        guard let step = step(at: index) else { return true }
        return GroupFormValidator.errors(for: step, values: formStore.values, context: validationContext()).isEmpty
    }

    override func displayErrors(forStepAt index: Int?) {
        if let index = index, let step = step(at: index) {
            formStore.errors = GroupFormValidator.errors(for: step, values: formStore.values, context: validationContext())
        }
        else {
            formStore.errors = [:]
        }
    }

    override func firstInvalidStepIndex() -> Int? {
        guard let step = GroupFormValidator.firstInvalidStep(values: formStore.values, context: validationContext()) else { return nil }
        return GroupFormPage.step(step).index
    }

    override func makePage(at index: Int) -> UIViewController? {
        switch GroupFormPage.all[min(max(index, 0), GroupFormPage.lastIndex)] {
        case .preview:
            return FormFlowHostViewController(GroupPreviewView(store: formStore))
        case .step(.details):
            return FormFlowHostViewController(GroupStepDetailsView(store: formStore, onPickPlace: { [weak self] in self?.showPlacePicker() }))
        case .step(.interests):
            // Les catégories sont celles de l'app (Metadatas) ; la sélection vit dans le formulaire.
            let tags = (Metadatas.sharedInstance.tagsInterest?.getTags() ?? []).map { (key: $0.key, name: $0.name) }
            return FormFlowHostViewController(GroupStepInterestsView(store: formStore, tags: tags))
        case .step(.photo):
            return FormFlowHostViewController(GroupStepPhotoView(store: formStore, onPickPhoto: { [weak self] in self?.showChoosePhoto() }))
        }
    }

    override func pageDidShow(at index: Int) {
        guard !isEditMode, let step = step(at: index) else { return }
        switch step {
        case .details: AnalyticsLoggerManager.logEvent(name: View_NewGroup_Step1)
        case .interests: AnalyticsLoggerManager.logEvent(name: View_NewGroup_Step2)
        case .photo: AnalyticsLoggerManager.logEvent(name: View_NewGroup_Step3)
        }
    }

    // MARK: Cycle de vie -

    override func viewDidLoad() {
        super.viewDidLoad()
        if isEditMode {
            AnalyticsLoggerManager.logEvent(name: View_GroupOption_Edition)
            getCurrentNeighborhood()
        }
    }

    /// Recharge le groupe. Les valeurs de référence deviennent celles du serveur ; les modifications
    /// déjà saisies par l'admin sont conservées.
    private func getCurrentNeighborhood() {
        guard let id = neighborhoodId else { return }
        NeighborhoodService.getNeighborhoodDetail(id: String(id)) { [weak self] group, error in
            guard let self = self else { return }
            if error != nil || group == nil {
                if self.currentNeighborhood == nil { self.dismiss(animated: true) }
                return
            }
            guard let group = group else { return }
            self.currentNeighborhood = group
            let fresh = GroupFormValues(neighborhood: group)
            let hadNoEdits = self.formStore.values == self.initialValues
            self.initialValues = fresh
            if hadNoEdits {
                self.formStore.values = fresh
            }
        }
    }

    // MARK: Sélecteurs (lieu, photo) -

    private func showPlacePicker() {
        AnalyticsLoggerManager.logEvent(name: Action_NewGroup_AddLocation)
        let sb = UIStoryboard(name: StoryboardName.profileParams, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "place_choose_vc") as? ParamsChoosePlaceViewController {
            vc.placeVCDelegate = self
            present(vc, animated: true)
        }
    }

    private func showChoosePhoto() {
        AnalyticsLoggerManager.logEvent(name: Action_NewGroup_Step3_AddPicture)
        let sb = UIStoryboard(name: StoryboardName.neighborhoodCreate, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "neighborhoodChoosePhotoVC") as? NeighborhoodChoosePictureViewController {
            vc.delegate = self
            present(vc, animated: true)
        }
    }

    // MARK: Réseau -

    override func publish() {
        if isEditMode {
            updateGroup()
        }
        else {
            createGroup()
        }
    }

    private func createGroup() {
        let group = formStore.values.makeNeighborhood()
        SVProgressHUD.show()
        NeighborhoodService.createNeighborhood(group: group) { [weak self] created, error in
            SVProgressHUD.dismiss()
            guard let self = self else { return }
            if let created = created {
                self.goEnd(neighborhood: created)
            }
            else {
                SVProgressHUD.showError(withStatus: "group_form_create_error".localized)
            }
        }
    }

    private func updateGroup() {
        guard let id = neighborhoodId else { return }
        let group = formStore.values.makeEditing(id: id, initial: initialValues)
        SVProgressHUD.show()
        NeighborhoodService.updateNeighborhood(group: group) { [weak self] updated, error in
            SVProgressHUD.dismiss()
            guard let self = self else { return }
            if let updated = updated {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNeighborhoodUpdate), object: nil, userInfo: ["neighborhood": updated])
                self.dismiss(animated: true)
            }
            else {
                SVProgressHUD.showError(withStatus: "group_form_update_error".localized)
            }
        }
    }

    private func goEnd(neighborhood: Neighborhood) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNeighborhoodCreateEnd), object: nil)
        let sb = UIStoryboard(name: StoryboardName.neighborhoodCreate, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "neighb_validateVC") as? NeighborhoodCreateValidateViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.newNeighborhood = neighborhood
            let parent = parentController
            dismiss(animated: false) {
                parent?.present(vc, animated: true)
            }
        }
    }
}

// MARK: - PlaceViewControllerDelegate -
extension GroupFormContainerViewController: PlaceViewControllerDelegate {
    func modifyPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        if let currentlocation = currentlocation {
            formStore.setPlace(name: currentLocationName ?? "", latitude: currentlocation.latitude, longitude: currentlocation.longitude, googlePlaceId: nil)
        }
        else if let googlePlace = googlePlace {
            // Lieu Google : nom + identifiant (pas de coordonnées dans la requête, comme avant la refonte).
            formStore.setPlace(name: googlePlace.name ?? googlePlace.formattedAddress ?? "", latitude: nil, longitude: nil, googlePlaceId: googlePlace.placeID)
        }
    }
}

// MARK: - ChoosePictureNeighborhoodDelegate -
extension GroupFormContainerViewController: ChoosePictureNeighborhoodDelegate {
    func selectedPicture(image: NeighborhoodImage) {
        formStore.setGalleryImage(image)
    }
}
