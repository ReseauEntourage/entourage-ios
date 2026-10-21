//
//  EventFormContainerViewController.swift
//  entourage
//
//  Conteneur commun du parcours de création (EventCreateMainViewController) et de
//  modification (EventEditMainViewController) d'un événement. L'habillage (barre de
//  progression, pied de page Retour / Continuer, navigation, erreurs sous les champs)
//  vit dans `FormFlowContainerViewController` ; ce contrôleur ne porte que ce qui est propre
//  à l'événement : étapes (`EventCreateStep`), validation, écrans de la storyboard.
//
//  Le nombre d'étapes est dérivé de `EventCreateStep.all` / `EventFormPage.all`.
//  Les deux conteneurs ne diffèrent que par leurs « hooks » (valeurs initiales,
//  publication, brouillon, textes de sortie).
//

import UIKit
import CoreLocation
import SVProgressHUD

// MARK: - Délégué partagé par les étapes -

protocol EventCreateMainDelegate: AnyObject {
    /// Etat du formulaire, observé et modifié directement par les étapes.
    var formStore: EventFormStore { get }

    func showChooseImage(delegate: ChoosePictureEventDelegate)
    func addCustomPhoto(image: UIImage)

    /// Utilisés pour l'édition (récurrence, bornes de dates).
    func isEdit() -> Bool
    func getCurrentEvent() -> Event?
    func hasCurrentRecurrency() -> Bool
    func initialFormValues() -> EventFormValues

    func getNeighborhoodId() -> Int?
}

// MARK: - Conteneur -

class EventFormContainerViewController: FormFlowContainerViewController, EventCreateMainDelegate {

    // Outlets historiques de la storyboard (Event_Create.storyboard). Ils restent déclarés pour que les
    // connexions de la scène restent valides ; l'ancien habillage est masqué, seul `ui_container_view`
    // (qui contient la page des étapes) est réutilisé.
    @IBOutlet weak var ui_page_control: MJCustomPageControl!
    @IBOutlet weak var ui_error_view: MJErrorInputView!
    @IBOutlet weak var ui_title_phase_nb: UILabel!
    @IBOutlet weak var ui_title_phase: UILabel!
    @IBOutlet weak var ui_main_container_view: UIView!
    @IBOutlet weak var ui_container_view: UIView!
    @IBOutlet weak var ui_bt_previous: UIButton!
    @IBOutlet weak var ui_bt_next: UIButton!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    weak var parentDelegate: UserProfileDetailDelegate? = nil

    var currentNeighborhoodId: Int? = nil

    var pageViewController: EventCreatePageViewController? = nil

    let formStore = EventFormStore()

    /// Valeurs de référence : sert à savoir s'il y a des modifications non enregistrées.
    var initialValues = EventFormValues()

    // MARK: Hooks du conteneur générique -

    override var pageCount: Int { return EventFormPage.count }
    override func hasUnsavedChanges() -> Bool { return formStore.values != initialValues }
    override var isUploadingPhoto: Bool { return formStore.isUploadingPhoto }

    override func observeValues(_ onChange: @escaping () -> Void) {
        formStore.onValuesChange = onChange
    }

    private func step(at index: Int) -> EventCreateStep? {
        guard index >= 0, index < EventFormPage.count, case .step(let step) = EventFormPage.all[index] else { return nil }
        return step
    }

    override func isStepValid(at index: Int) -> Bool {
        guard let step = step(at: index) else { return true }
        return EventFormValidator.errors(for: step, values: formStore.values, context: validationContext()).isEmpty
    }

    override func displayErrors(forStepAt index: Int?) {
        if let index = index, let step = step(at: index) {
            formStore.errors = EventFormValidator.errors(for: step, values: formStore.values, context: validationContext())
        }
        else {
            formStore.errors = [:]
        }
    }

    override func firstInvalidStepIndex() -> Int? {
        guard let step = EventFormValidator.firstInvalidStep(values: formStore.values, context: validationContext()) else { return nil }
        return EventFormPage.step(step).index
    }

    /// Les étapes de l'événement viennent de la storyboard (`EventCreatePageViewController`).
    override func prepareContentContainer() -> UIView {
        // On masque l'ancien habillage (en-tête, bloc beige, pagination, boutons, bandeau d'erreur).
        view.subviews.forEach { $0.isHidden = true }

        // Seule la zone qui contient la page des étapes est conservée.
        ui_container_view.removeFromSuperview()
        ui_container_view.translatesAutoresizingMaskIntoConstraints = false
        ui_container_view.backgroundColor = .white
        ui_container_view.layer.cornerRadius = 0
        ui_container_view.isHidden = false
        pageHost = pageViewController
        return ui_container_view
    }

    func validationContext() -> EventFormValidationContext { return EventFormValidationContext() }

    /// Force l'affichage des erreurs d'une étape (brouillon restauré dont une valeur est devenue obsolète).
    func markStepAttempted(_ step: EventCreateStep) {
        markStepAttempted(at: EventFormPage.step(step).index)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EventCreatePageViewController {
            pageViewController = vc
            vc.parentDelegate = self
            vc.isCreating = !isEdit()
        }
    }

    /// Ouvre directement la page d'une étape (reprise d'un brouillon).
    func pageIndex(of step: EventCreateStep) -> Int {
        return EventFormPage.step(step).index
    }

    // MARK: EventCreateMainDelegate -

    func isEdit() -> Bool { return false }
    func getCurrentEvent() -> Event? { return nil }
    func hasCurrentRecurrency() -> Bool { return false }
    func initialFormValues() -> EventFormValues { return initialValues }
    func getNeighborhoodId() -> Int? { return currentNeighborhoodId }

    func showChooseImage(delegate: ChoosePictureEventDelegate) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "eventChoosePhotoVC") as? EventChoosePictureViewController {
            vc.delegate = delegate
            present(vc, animated: true)
        }
    }

    func addCustomPhoto(image: UIImage) {
        formStore.isUploadingPhoto = true
        SVProgressHUD.show()
        EventCoverUploadPictureService.prepareUploadWith(image: image) { [weak self] uploadKey in
            SVProgressHUD.dismiss()
            guard let self = self else { return }
            self.formStore.isUploadingPhoto = false
            if let uploadKey = uploadKey {
                self.formStore.setUploadedImage(key: uploadKey, image: image)
            }
            else {
                let errorVC = MJErrorInputView()
                errorVC.changeTitleAndImage(title: "neighborhood_choosephoto_error".localized)
                errorVC.show()
            }
        }
    }
}
