//
//  EventCreateMainViewController.swift
//  entourage
//
//  Created by Jerome on 21/06/2022.
//
//  Création d'un événement. L'habillage commun (progression, étapes, pied de page,
//  aperçu) est dans `EventFormContainerViewController` ; ce contrôleur porte la
//  création : duplication, brouillon local persistant, envoi.
//

import UIKit
import SVProgressHUD

class EventCreateMainViewController: EventFormContainerViewController {

    /// Evénement à dupliquer (dates effacées, l'organisateur choisit les nouvelles).
    var sourceEvent: Event? = nil

    private var restoredPageIndex: Int? = nil

    /// « Enregistrer » (brouillon) est masqué : le code du brouillon est conservé mais inaccessible,
    /// et la création ne restaure plus de brouillon.
    override var supportsDraft: Bool { return false }
    override var finalActionTitle: String { return "event_form_publish".localized }
    override var startPageIndex: Int { return restoredPageIndex ?? 0 }

    // MARK: Etat initial : duplication éventuelle (plus de restauration de brouillon) -

    override func loadInitialState() {
        var values = EventFormValues()

        if let source = sourceEvent {
            values = EventFormValues(event: source, forDuplication: true)
        }

        // Création depuis la page d'un groupe : ce groupe est pré-sélectionné pour le partage.
        if values.groups.isEmpty, let groupId = currentNeighborhoodId {
            values.groups = [EventNeighborhood(id: groupId, name: "")]
        }

        formStore.values = values
        initialValues = values
    }

    /// Revalidation du brouillon : si une étape déjà franchie contient une valeur devenue
    /// obsolète (date passée, par exemple), on ouvre cette étape avec son erreur plutôt que
    /// de corriger silencieusement.
    private func restoreDraftPosition(_ draft: EventFormDraft) {
        let savedIndex = min(max(draft.pageIndex, 0), EventFormPage.lastIndex)
        var startIndex = savedIndex
        for step in EventCreateStep.all {
            let index = EventFormPage.step(step).index
            guard index < savedIndex else { break }
            if !EventFormValidator.errors(for: step, values: draft.values, context: validationContext()).isEmpty {
                markStepAttempted(step)
                startIndex = index
                break
            }
        }
        restoredPageIndex = startIndex
    }

    // MARK: Brouillon local -

    override func saveDraft() {
        guard let userId = EventDraftStore.currentUserId else {
            dismiss(animated: true)
            return
        }
        let values = formStore.values
        if values == EventFormValues() {
            // Formulaire vide : rien à reprendre, on ne remplace pas un brouillon existant par du vide.
            EventDraftStore.delete(userId: userId)
        }
        else {
            EventDraftStore.save(EventFormDraft(values: values, pageIndex: currentPageIndex), userId: userId)
        }
        SVProgressHUD.showSuccess(withStatus: "event_form_draft_saved".localized)
        dismiss(animated: true)
    }

    // MARK: Réseau -

    override func publish() {
        let event = formStore.values.makeEvent()
        SVProgressHUD.show()
        Logger.print("***** createEvent \(event.dictionaryForWS())")
        EventService.createEvent(event: event) { [weak self] created, error in
            SVProgressHUD.dismiss()
            guard let self = self else { return }
            if let created = created {
                if let userId = EventDraftStore.currentUserId {
                    EventDraftStore.delete(userId: userId)
                }
                self.goEnd(event: created)
            }
            else {
                SVProgressHUD.showError(withStatus: "event_create_ok".localized)
            }
        }
    }

    private func goEnd(event: Event) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationEventCreateEnd), object: nil)
        if let vc = storyboard?.instantiateViewController(withIdentifier: "event_validateVC") as? EventCreateValidateViewController {
            AnalyticsLoggerManager.logEvent(name: Event_create_end)
            vc.modalPresentationStyle = .fullScreen
            vc.eventId = event.uid
            self.dismiss(animated: false) {
                self.parentController?.present(vc, animated: true)
            }
        }
    }
}
