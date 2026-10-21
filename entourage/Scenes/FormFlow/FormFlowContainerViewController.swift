//
//  FormFlowContainerViewController.swift
//  entourage
//
//  Conteneur générique des parcours de création / modification « un écran, une question » :
//  barre de progression, pied de page Retour / Continuer, navigation entre les étapes puis
//  l'aperçu, erreurs sous les champs (affichées après « Continuer », bouton jamais grisé),
//  confirmation à la sortie.
//
//  Extrait du conteneur de l'événement (refonte EN-9578) pour être réutilisé par les parcours
//  groupe et entraide (change flux-creation-unifie). Le nombre d'étapes est TOUJOURS dérivé
//  d'une liste (`pageCount`) : un parcours peut la modifier à tout moment (étape de partage de
//  l'entraide) et appeler `pagesDidChange()`.
//
//  Chaque parcours fournit ses « hooks » : liste des pages, validation par étape, création des
//  écrans, envoi final, textes de sortie. L'aperçu est toujours la dernière page.
//

import UIKit
import SVProgressHUD

/// Affiche une page du parcours (UIPageViewController du conteneur, ou celui de la storyboard de l'événement).
protocol FormFlowPageHost: AnyObject {
    func showPage(at index: Int, animated: Bool)
}

class FormFlowContainerViewController: UIViewController {

    weak var parentController: UIViewController? = nil // Utilisé pour ouvrir l'écran de fin

    private(set) var currentPageIndex = 0
    /// Pages sur lesquelles l'utilisateur a déjà appuyé sur « Continuer » (les erreurs s'y affichent).
    private var attemptedPages = Set<Int>()
    private var knownPageCount = 0

    /// Hôte des pages (fourni par `prepareContentContainer()`).
    var pageHost: FormFlowPageHost?

    // Habillage
    private let backButton = UIButton(type: .custom)
    private let saveButton = UIButton(type: .custom)
    private let progressView = ProgressRadiusView()
    /// Pied de page : mêmes boutons que l'onboarding enrichi (Retour = bouton blanc contour orange,
    /// Continuer / Publier / Modifier = bouton orange plein).
    private var footerView: EnahancedOnboardingButtonCell!
    private var previousButton: UIButton { return footerView.ui_btn_configure_later }
    private var nextButton: UIButton { return footerView.ui_btn_next }

    // MARK: Hooks à surcharger -

    /// Nombre de pages, aperçu compris (l'aperçu est la dernière). Toujours dérivé de la liste d'étapes.
    var pageCount: Int { return 1 }
    var stepCount: Int { return max(pageCount - 1, 1) }
    var lastPageIndex: Int { return max(pageCount - 1, 0) }
    func isPreviewPage(_ index: Int) -> Bool { return index == lastPageIndex }

    /// Création : brouillon local proposé (événement). Sinon jamais.
    var supportsDraft: Bool { return false }
    var continueTitle: String { return "event_form_continue".localized }
    var finalActionTitle: String { return "event_form_publish".localized }
    var quitAlertKeys: (title: String, message: String, quit: String, cancel: String) {
        return ("eventCreatePopCloseBackTitle", "eventCreatePopCloseBackMessage", "eventCreatePopCloseBackQuit", "eventCreatePopCloseBackCancel")
    }
    /// Textes déjà localisés de la confirmation de sortie.
    func quitAlertStrings() -> (title: String, message: String, quit: String, cancel: String) {
        let keys = quitAlertKeys
        return (keys.title.localized, keys.message.localized, keys.quit.localized, keys.cancel.localized)
    }

    /// Charge les valeurs du formulaire avant la construction de l'écran.
    func loadInitialState() {}
    /// Branche l'observation du store du parcours : `onChange` doit être appelé après chaque modification.
    func observeValues(_ onChange: @escaping () -> Void) {}
    /// Index de page affiché à l'ouverture (reprise d'un brouillon).
    var startPageIndex: Int { return 0 }
    func hasUnsavedChanges() -> Bool { return false }
    /// Une photo est en cours d'envoi : on n'ouvre pas l'aperçu.
    var isUploadingPhoto: Bool { return false }

    /// L'étape est-elle valide ?
    func isStepValid(at index: Int) -> Bool { return true }
    /// Affiche (ou efface avec `nil`) les erreurs de l'étape dans le store du parcours.
    func displayErrors(forStepAt index: Int?) {}
    /// Première étape invalide, utilisée avant l'envoi (brouillon obsolète, etc.).
    func firstInvalidStepIndex() -> Int? {
        for index in 0..<lastPageIndex where !isStepValid(at: index) { return index }
        return nil
    }

    /// Crée l'écran d'une page (utilisé par le conteneur de pages par défaut).
    func makePage(at index: Int) -> UIViewController? { return nil }
    /// Identifiant stable d'une page (le cache d'écrans en dépend : l'étape de partage peut disparaître).
    func pageIdentifier(at index: Int) -> AnyHashable { return index }
    /// Une page vient d'être affichée (mesure d'audience).
    func pageDidShow(at index: Int) {}

    /// Prépare la zone qui contient les pages et la renvoie. Par défaut : une zone vide avec son
    /// conteneur de pages ; l'événement réutilise celle de sa storyboard.
    func prepareContentContainer() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        let host = FormFlowPageViewController()
        host.owner = self
        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: container.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        host.didMove(toParent: self)
        pageHost = host
        return container
    }

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
        observeValues { [weak self] in self?.valuesDidChange() }

        buildChrome()
        showPage(at: startPageIndex, animated: false)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { return .darkContent }

    // MARK: Construction de l'écran -

    private func buildChrome() {
        view.backgroundColor = .white

        let contentContainer = prepareContentContainer()
        view.addSubview(contentContainer)

        // Barre du haut : retour (quitte le parcours) et « Enregistrer ».
        let topBar = UIView()
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = FormFlowStyle.uiInk
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

        // Pied de page : Retour / Continuer (cellule de boutons de l'onboarding enrichi).
        guard let buttonView = Bundle.main.loadNibNamed("EnahancedOnboardingButtonCell", owner: self, options: nil)?.first as? EnahancedOnboardingButtonCell else {
            return
        }
        footerView = buttonView
        footerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(footerView)
        previousButton.setTitle("event_form_back".localized, for: .normal)
        previousButton.addTarget(self, action: #selector(action_back(_:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(action_next(_:)), for: .touchUpInside)

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

            // Même géométrie que le pied de page de l'onboarding enrichi (EnhancedViewController).
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: safe.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 85),

            contentContainer.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: footerView.topAnchor)
        ])
    }

    private func underlined(_ text: String, font: UIFont) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: FormFlowStyle.uiInk,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
    }

    // MARK: Navigation -

    private func showPage(at index: Int, animated: Bool) {
        currentPageIndex = min(max(index, 0), lastPageIndex)
        pageHost?.showPage(at: currentPageIndex, animated: animated)
        pageDidShow(at: currentPageIndex)
        refreshErrors()
        refreshChrome()
        view.endEditing(true)
    }

    /// À appeler quand la liste d'étapes a changé (ajout / retrait d'une étape) : met à jour la
    /// progression et le libellé du bouton sans changer de page.
    func pagesDidChange() {
        if currentPageIndex > lastPageIndex {
            showPage(at: lastPageIndex, animated: false)
            return
        }
        refreshChrome()
    }

    private func refreshChrome() {
        guard footerView != nil else { return }
        knownPageCount = pageCount
        if isPreviewPage(currentPageIndex) {
            progressView.progressPercent = 100
            nextButton.setTitle(finalActionTitle, for: .normal)
        }
        else {
            progressView.progressPercent = CGFloat(currentPageIndex + 1) / CGFloat(stepCount) * 100
            nextButton.setTitle(continueTitle, for: .normal)
        }
        progressView.setNeedsDisplay()
        previousButton.isHidden = currentPageIndex == 0
        saveButton.isHidden = !supportsDraft
    }

    private func refreshErrors() {
        if !isPreviewPage(currentPageIndex), attemptedPages.contains(currentPageIndex) {
            displayErrors(forStepAt: currentPageIndex)
        }
        else {
            displayErrors(forStepAt: nil)
        }
    }

    /// Revalide l'étape courante à chaque modification, mais seulement une fois que
    /// l'utilisateur a appuyé sur « Continuer » (les messages disparaissent quand le champ est corrigé).
    func valuesDidChange() {
        if pageCount != knownPageCount { pagesDidChange() }
        guard !isPreviewPage(currentPageIndex), attemptedPages.contains(currentPageIndex) else { return }
        displayErrors(forStepAt: currentPageIndex)
    }

    /// Force l'affichage des erreurs d'une étape (brouillon restauré dont une valeur est devenue obsolète).
    func markStepAttempted(at index: Int) {
        attemptedPages.insert(index)
    }

    @IBAction func action_next(_ sender: Any) {
        if isPreviewPage(currentPageIndex) {
            publishTapped()
            return
        }
        attemptedPages.insert(currentPageIndex)
        displayErrors(forStepAt: currentPageIndex)
        guard isStepValid(at: currentPageIndex) else { return }
        goToNextPage()
    }

    @IBAction func action_back(_ sender: Any) {
        showPage(at: currentPageIndex - 1, animated: true)
    }

    private func goToNextPage() {
        let next = currentPageIndex + 1
        if isPreviewPage(min(next, lastPageIndex)) {
            guard !isUploadingPhoto else { return }
            // Avant l'aperçu, toutes les étapes doivent être valides (une étape d'un brouillon obsolète, par exemple).
            if let invalid = firstInvalidStepIndex() {
                attemptedPages.insert(invalid)
                showPage(at: invalid, animated: true)
                return
            }
        }
        showPage(at: next, animated: true)
    }

    private func publishTapped() {
        guard !isUploadingPhoto else { return }
        if let invalid = firstInvalidStepIndex() {
            attemptedPages.insert(invalid)
            showPage(at: invalid, animated: true)
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

        let strings = quitAlertStrings()
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: strings.cancel, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
        let buttonValidate = MJAlertButtonType(title: strings.quit, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        alertVC.configureAlert(alertTitle: strings.title, message: strings.message, buttonrightType: buttonValidate, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true)
        alertVC.delegate = self
        alertVC.show()
    }
}

// MARK: - MJAlertControllerDelegate -
extension FormFlowContainerViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag: MJAlertTAG) {
    }

    func validateRightButton(alertTag: MJAlertTAG) {
        handleAlertConfirmed(tag: alertTag)
    }
}

// MARK: - Conteneur de pages par défaut -

/// Pages du parcours (un écran SwiftUI par étape, puis l'aperçu). Les écrans sont créés par le
/// conteneur (`makePage(at:)`) et mis en cache par identifiant de page.
final class FormFlowPageViewController: UIPageViewController, FormFlowPageHost {

    weak var owner: FormFlowContainerViewController?

    private var currentIndex = 0
    private var cache = [AnyHashable: UIViewController]()

    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        isPagingEnabled = false
    }

    private func viewController(at index: Int) -> UIViewController? {
        guard let owner = owner else { return nil }
        let id = owner.pageIdentifier(at: index)
        if let cached = cache[id] { return cached }
        guard let vc = owner.makePage(at: index) else { return nil }
        cache[id] = vc
        return vc
    }

    func showPage(at index: Int, animated: Bool) {
        loadViewIfNeeded()
        let direction: UIPageViewController.NavigationDirection = currentIndex > index ? .reverse : .forward
        currentIndex = index
        guard let vc = viewController(at: index) else { return }
        setViewControllers([vc], direction: direction, animated: animated)
    }
}
