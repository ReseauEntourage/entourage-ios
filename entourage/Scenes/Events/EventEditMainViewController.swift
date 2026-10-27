//
//  EventEditViewController.swift
//  entourage
//
//  Created by Jerome on 30/06/2022.
//
//  Modification d'un événement. L'habillage commun (progression, étapes, pied de page,
//  aperçu) est dans `EventFormContainerViewController` ; ce contrôleur porte la
//  modification : valeurs initiales de l'événement, envoi des seuls champs modifiés,
//  choix « cet événement / tous les événements » pour une série. Jamais de brouillon.
//

import UIKit
import SVProgressHUD

class EventEditMainViewController: EventFormContainerViewController {

    var eventId: Int = 0
    var currentEvent: Event? = nil
    var hasRecurrency = false

    private var selectedRecurrencyPosition = 0

    override var supportsDraft: Bool { return false }
    override var finalActionTitle: String { return "event_mod_group_bt_mod".localized }
    override var quitAlertKeys: (title: String, message: String, quit: String, cancel: String) {
        return ("eventModPopCloseBackTitle", "eventModPopCloseBackMessage", "eventModPopCloseBackQuit", "eventModPopCloseBackCancel")
    }

    override func isEdit() -> Bool { return true }
    override func getCurrentEvent() -> Event? { return currentEvent }
    override func hasCurrentRecurrency() -> Bool { return hasRecurrency }
    override func getNeighborhoodId() -> Int? { return nil }

    override func loadInitialState() {
        if let event = currentEvent {
            let values = EventFormValues(event: event)
            formStore.values = values
            initialValues = values
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getEvent()
    }

    /// En modification, les contrôles portent sur ce que l'organisateur a changé :
    /// une date passée ou un ancien lien inchangés ne bloquent pas l'enregistrement.
    override func validationContext() -> EventFormValidationContext {
        let values = formStore.values
        var context = EventFormValidationContext()
        context.isEdit = true
        context.checkPastDates = values.day != initialValues.day
            || values.startMinutes != initialValues.startMinutes
            || values.endMinutes != initialValues.endMinutes
        context.unchangedOnlineUrl = initialValues.isOnline ? initialValues.onlineUrl : nil
        return context
    }

    // MARK: Réseau -

    /// Recharge l'événement. Les valeurs de référence deviennent celles du serveur ; les
    /// modifications déjà saisies par l'organisateur sont conservées.
    private func getEvent() {
        EventService.getEventWithId(String(eventId)) { [weak self] event, _ in
            guard let self = self, let event = event else { return }
            self.currentEvent = event
            let fresh = EventFormValues(event: event)
            let hadNoEdits = self.formStore.values == self.initialValues
            self.initialValues = fresh
            if hadNoEdits {
                self.formStore.values = fresh
            }
        }
    }

    override func publish() {
        if !hasUnsavedChanges() {
            SVProgressHUD.showSuccess(withStatus: "event_mod_ok".localized)
            goEnd()
            return
        }
        if hasRecurrency {
            showPopRecurrency()
        }
        else {
            updateEvent(applyToAll: false)
        }
    }

    private func updateEvent(applyToAll: Bool) {
        let editing = formStore.values.makeEditing(eventId: eventId, initial: initialValues)
        SVProgressHUD.show()
        Logger.print("***** updateEvent \(editing.dictionaryForWS())")
        EventService.updateEvent(event: editing, isWithRecurrency: applyToAll) { [weak self] event, error in
            SVProgressHUD.dismiss()
            if error != nil {
                SVProgressHUD.showError(withStatus: "event_mod_nok".localized)
            }
            else {
                self?.goEnd()
            }
        }
    }

    private func showPopRecurrency() {
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "event_mod_pop_validate_bt".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)

        customAlert.configurePopWithChoice(alertTitle: "event_mod_pop_title".localized, choice1: "params_cancel_event_recurrency_choice1".localized, choice2: "params_cancel_event_recurrency_choice2".localized, buttonrightType: buttonAccept, buttonLeftType: nil, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), choiceStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35)

        customAlert.alertTagName = .Suppress
        customAlert.delegate = self
        customAlert.show()
    }

    private func goEnd() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationEventUpdate), object: nil)

        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }

    // MARK: Alertes -

    override func handleAlertConfirmed(tag: MJAlertTAG) {
        if tag == .Suppress {
            // Choix 1 : tous les événements (batch_update), sinon cet événement seulement.
            updateEvent(applyToAll: selectedRecurrencyPosition == 1)
        }
        else {
            super.handleAlertConfirmed(tag: tag)
        }
    }

    override func selectedChoice(position: Int) {
        selectedRecurrencyPosition = position
    }
}
