//
//  EventFormContainerViewController.swift
//  entourage
//
//  Conteneur commun du parcours de création (EventCreateMainViewController) et de
//  modification (EventEditMainViewController) d'un événement : barre de progression,
//  libellé « Étape N sur X », pied de page Retour / Continuer, navigation entre les
//  étapes puis l'aperçu, erreurs sous les champs.
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

class EventFormContainerViewController: UIViewController, EventCreateMainDelegate {

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

    weak var parentController: UIViewController? = nil // Use to open the ending screen
    var currentNeighborhoodId: Int? = nil

    var pageViewController: EventCreatePageViewController? = nil

    let formStore = EventFormStore()

    /// Valeurs de référence : sert à savoir s'il y a des modifications non enregistrées.
    var initialValues = EventFormValues()

    private(set) var currentPageIndex = 0
    /// Etapes sur lesquelles l'utilisateur a déjà appuyé sur « Continuer » (les erreurs s'y affichent).
    private var attemptedSteps = Set<EventCreateStep>()

    // Nouveau habillage
    private let backButton = UIButton(type: .custom)
    private let saveButton = UIButton(type: .custom)
    private let progressView = ProgressRadiusView()
    private let footerView = UIView()
    private let previousButton = UIButton(type: .custom)
    private let nextButton = UIButton(type: .custom)

    // MARK: Hooks à surcharger -

    /// Création : brouillon local proposé. Edition : jamais de brouillon.
    var supportsDraft: Bool { return false }
    var finalActionTitle: String { return "event_form_publish".localized }
    var quitAlertKeys: (title: String, message: String, quit: String, cancel: String) {
        return ("eventCreatePopCloseBackTitle", "eventCreatePopCloseBackMessage", "eventCreatePopCloseBackQuit", "eventCreatePopCloseBackCancel")
    }

    /// Charge `formStore.values` / `initialValues` avant la construction de l'écran.
    func loadInitialState() {}
    /// Index de page affiché à l'ouverture (reprise d'un brouillon).
    var startPageIndex: Int { return 0 }
    func validationContext() -> EventFormValidationContext { return EventFormValidationContext() }
    func hasUnsavedChanges() -> Bool { return formStore.values != initialValues }
    /// Envoi final (appelé depuis l'aperçu, après revalidation de toutes les étapes).
    func publish() {}
    func saveDraft() {}
    func handleAlertConfirmed(tag: MJAlertTAG) {
        if tag == .None { dismiss(animated: true) }
    }
    /// Choix d'une alerte à choix multiples (modification d'un événement récurrent).
    func selectedChoice(position: Int) {}

    // MARK: Cycle de vie -

    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .fullScreen

        loadInitialState()
        formStore.onValuesChange = { [weak self] in self?.valuesDidChange() }

        buildChrome()
        showPage(at: startPageIndex, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EventCreatePageViewController {
            pageViewController = vc
            vc.parentDelegate = self
            vc.isCreating = !isEdit()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { return .darkContent }

    // MARK: Construction de l'écran -

    private func buildChrome() {
        view.backgroundColor = .white

        // On masque l'ancien habillage (en-tête, bloc beige, pagination, boutons, bandeau d'erreur).
        view.subviews.forEach { $0.isHidden = true }

        // Seule la zone qui contient la page des étapes est conservée.
        ui_container_view.removeFromSuperview()
        ui_container_view.translatesAutoresizingMaskIntoConstraints = false
        ui_container_view.backgroundColor = .white
        ui_container_view.layer.cornerRadius = 0
        ui_container_view.isHidden = false
        view.addSubview(ui_container_view)

        // Barre du haut : retour (quitte le parcours) et « Enregistrer ».
        let topBar = UIView()
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = EventFormStyle.uiInk
        backButton.layer.cornerRadius = 16.5
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor(red: 221 / 255, green: 221 / 255, blue: 221 / 255, alpha: 1).cgColor
        backButton.accessibilityLabel = "event_form_back".localized
        backButton.addTarget(self, action: #selector(quitTapped), for: .touchUpInside)
        topBar.addSubview(backButton)

        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setAttributedTitle(underlined("event_form_save".localized, font: ApplicationTheme.getFontNunitoSemiBold(size: 14)), for: .normal)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        saveButton.isHidden = !supportsDraft
        topBar.addSubview(saveButton)

        // Barre de progression (composant existant ProgressRadiusView).
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.backgroundColor = .clear
        progressView.isOpaque = false
        view.addSubview(progressView)

        // Pied de page : Retour / Continuer.
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.backgroundColor = .white
        view.addSubview(footerView)

        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = EventFormStyle.uiLine2
        footerView.addSubview(separator)

        previousButton.translatesAutoresizingMaskIntoConstraints = false
        previousButton.setAttributedTitle(underlined("event_form_back".localized, font: ApplicationTheme.getFontNunitoSemiBold(size: 14.5)), for: .normal)
        previousButton.addTarget(self, action: #selector(action_back(_:)), for: .touchUpInside)
        footerView.addSubview(previousButton)

        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.backgroundColor = .appOrange
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 15)
        nextButton.layer.cornerRadius = 12
        nextButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 28)
        nextButton.addTarget(self, action: #selector(action_next(_:)), for: .touchUpInside)
        footerView.addSubview(nextButton)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // Marge sous la zone sûre (barre d'état / encoche / Dynamic Island).
            topBar.topAnchor.constraint(equalTo: safe.topAnchor, constant: 10),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 48),

            backButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 18),
            backButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 33),
            backButton.heightAnchor.constraint(equalToConstant: 33),

            saveButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -22),
            saveButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),

            progressView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 4),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -22),
            progressView.heightAnchor.constraint(equalToConstant: 4),

            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerView.topAnchor.constraint(equalTo: nextButton.topAnchor, constant: -12),

            separator.topAnchor.constraint(equalTo: footerView.topAnchor),
            separator.leadingAnchor.constraint(equalTo: footerView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: footerView.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),

            nextButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -22),
            nextButton.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -12),
            nextButton.heightAnchor.constraint(equalToConstant: 48),

            previousButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 22),
            previousButton.centerYAnchor.constraint(equalTo: nextButton.centerYAnchor),
            previousButton.heightAnchor.constraint(equalToConstant: 44),

            ui_container_view.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            ui_container_view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ui_container_view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ui_container_view.bottomAnchor.constraint(equalTo: footerView.topAnchor)
        ])
    }

    private func underlined(_ text: String, font: UIFont) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: EventFormStyle.uiInk,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
    }

    // MARK: Navigation -

    var currentPage: EventFormPage { return EventFormPage.all[currentPageIndex] }

    private func showPage(at index: Int, animated: Bool) {
        currentPageIndex = min(max(index, 0), EventFormPage.lastIndex)
        pageViewController?.goPage(currentPage, animated: animated)
        refreshErrors()
        refreshChrome()
        view.endEditing(true)
    }

    private func refreshChrome() {
        let page = currentPage
        switch page {
        case .step(let step):
            progressView.progressPercent = CGFloat(step.position) / CGFloat(EventCreateStep.count) * 100
            nextButton.setTitle("event_form_continue".localized, for: .normal)
        case .preview:
            progressView.progressPercent = 100
            nextButton.setTitle(finalActionTitle, for: .normal)
        }
        progressView.setNeedsDisplay()
        previousButton.isHidden = currentPageIndex == 0
        saveButton.isHidden = !supportsDraft
    }

    private func refreshErrors() {
        if case .step(let step) = currentPage, attemptedSteps.contains(step) {
            formStore.errors = EventFormValidator.errors(for: step, values: formStore.values, context: validationContext())
        }
        else {
            formStore.errors = [:]
        }
    }

    /// Revalide l'étape courante à chaque modification, mais seulement une fois que
    /// l'utilisateur a appuyé sur « Continuer » (les messages disparaissent quand le champ est corrigé).
    private func valuesDidChange() {
        guard case .step(let step) = currentPage, attemptedSteps.contains(step) else { return }
        formStore.errors = EventFormValidator.errors(for: step, values: formStore.values, context: validationContext())
    }

    /// Force l'affichage des erreurs d'une étape (brouillon restauré dont une valeur est devenue obsolète).
    func markStepAttempted(_ step: EventCreateStep) {
        attemptedSteps.insert(step)
    }

    @IBAction func action_next(_ sender: Any) {
        switch currentPage {
        case .step(let step):
            attemptedSteps.insert(step)
            let errors = EventFormValidator.errors(for: step, values: formStore.values, context: validationContext())
            formStore.errors = errors
            guard errors.isEmpty else { return }
            goToNextPage()
        case .preview:
            publishTapped()
        }
    }

    @IBAction func action_back(_ sender: Any) {
        showPage(at: currentPageIndex - 1, animated: true)
    }

    private func goToNextPage() {
        let next = currentPageIndex + 1
        if EventFormPage.all[min(next, EventFormPage.lastIndex)] == .preview {
            guard !formStore.isUploadingPhoto else { return }
            // Avant l'aperçu, toutes les étapes doivent être valides (une étape d'un brouillon obsolète, par exemple).
            if let invalid = EventFormValidator.firstInvalidStep(values: formStore.values, context: validationContext()) {
                attemptedSteps.insert(invalid)
                showPage(at: EventFormPage.step(invalid).index, animated: true)
                return
            }
        }
        showPage(at: next, animated: true)
    }

    private func publishTapped() {
        guard !formStore.isUploadingPhoto else { return }
        if let invalid = EventFormValidator.firstInvalidStep(values: formStore.values, context: validationContext()) {
            attemptedSteps.insert(invalid)
            showPage(at: EventFormPage.step(invalid).index, animated: true)
            return
        }
        publish()
    }

    @objc private func saveTapped() {
        guard supportsDraft else { return }
        saveDraft()
    }

    @objc private func quitTapped() {
        view.endEditing(true)
        if !hasUnsavedChanges() {
            dismiss(animated: true)
            return
        }

        let keys = quitAlertKeys
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: keys.cancel.localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
        let buttonValidate = MJAlertButtonType(title: keys.quit.localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        alertVC.configureAlert(alertTitle: keys.title.localized, message: keys.message.localized, buttonrightType: buttonValidate, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true)
        alertVC.delegate = self
        alertVC.show()
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

// MARK: - MJAlertControllerDelegate -
extension EventFormContainerViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag: MJAlertTAG) {
    }

    func validateRightButton(alertTag: MJAlertTAG) {
        handleAlertConfirmed(tag: alertTag)
    }
}
