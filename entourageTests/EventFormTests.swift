import XCTest
@testable import entourage

/// EN-9578 : refonte du parcours de création / modification d'événement (logique pure, sans réseau).
final class EventFormTests: XCTestCase {

    private let calendar = Calendar.current

    private func tomorrow() -> Date {
        return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))!
    }

    private func validValues() -> EventFormValues {
        var values = EventFormValues()
        values.title = "Discussion entre voisins"
        values.descriptionText = "Venez nombreux jouer à la pétanque avec nous"
        values.imageId = 3
        values.day = tomorrow()
        values.startMinutes = 16 * 60
        values.endMinutes = 18 * 60
        values.latitude = 48.85
        values.longitude = 2.35
        values.googlePlaceId = "place"
        values.addressName = "Paris"
        values.streetAddress = "Place des Fêtes, Paris"
        values.interests = ["sport"]
        return values
    }

    // MARK: - Étapes dérivées d'une liste unique

    func testStepCountIsDerivedFromTheList() {
        XCTAssertEqual(EventCreateStep.count, EventCreateStep.all.count)
        XCTAssertEqual(EventCreateStep.count, 5)
        // L'aperçu s'ajoute après la dernière étape sans compter dans « Étape N sur X ».
        XCTAssertEqual(EventFormPage.count, EventCreateStep.count + 1)
        XCTAssertEqual(EventFormPage.all.last, .preview)
        XCTAssertEqual(EventCreateStep.groups.position, EventCreateStep.count)
    }

    // MARK: - Messages d'erreur par champ

    func testPresentationErrors() {
        let errors = EventFormValidator.errors(for: .presentation, values: EventFormValues())
        XCTAssertEqual(errors[.title], "event_form_error_title".localized)
        XCTAssertEqual(errors[.description], "event_form_error_description".localized)
        XCTAssertEqual(errors[.photo], "event_form_error_photo".localized)
        XCTAssertTrue(EventFormValidator.errors(for: .presentation, values: validValues()).isEmpty)
    }

    func testDescriptionMinimumLength() {
        var values = validValues()
        values.descriptionText = "Trop court"
        XCTAssertEqual(EventFormValidator.errors(for: .presentation, values: values)[.description], "event_form_error_description_short".localized)
        XCTAssertNotEqual("event_form_error_description_short".localized, "event_form_error_description".localized)

        // Les espaces de bord ne comptent pas.
        values.descriptionText = String(repeating: " ", count: 40) + "court"
        XCTAssertEqual(EventFormValidator.errors(for: .presentation, values: values)[.description], "event_form_error_description_short".localized)

        values.descriptionText = String(repeating: "a", count: EventFormValidator.minDescriptionChars - 1)
        XCTAssertNotNil(EventFormValidator.errors(for: .presentation, values: values)[.description])
        values.descriptionText = String(repeating: "a", count: EventFormValidator.minDescriptionChars)
        XCTAssertNil(EventFormValidator.errors(for: .presentation, values: values)[.description])
    }

    func testFrenchMessagesFromProductOwner() {
        XCTAssertEqual(EventFormValidator.errors(for: .presentation, values: EventFormValues())[.title], "Donnez un nom à votre événement pour continuer.")
        XCTAssertEqual(EventFormValidator.errors(for: .presentation, values: EventFormValues())[.description], "Ajoutez quelques mots pour présenter votre événement.")
        XCTAssertEqual(EventFormValidator.errors(for: .presentation, values: EventFormValues())[.photo], "Ajoutez une photo pour continuer.")
    }

    func testOtherCategoryIsNotRequired() {
        var values = validValues()
        values.interests = [Tag.tagOther]
        XCTAssertNil(EventFormValidator.errors(for: .categories, values: values)[.categories])
        XCTAssertTrue(EventFormValidator.errors(for: .categories, values: values).isEmpty)
    }

    func testScheduleErrors() {
        var values = validValues()
        values.day = nil
        XCTAssertEqual(EventFormValidator.errors(for: .schedule, values: values)[.date], "event_form_error_date_empty".localized)

        values = validValues()
        values.day = calendar.date(byAdding: .day, value: -2, to: Date())
        XCTAssertEqual(EventFormValidator.errors(for: .schedule, values: values)[.date], "event_form_error_date_past".localized)

        values = validValues()
        values.startMinutes = 18 * 60
        values.endMinutes = 16 * 60
        XCTAssertEqual(EventFormValidator.errors(for: .schedule, values: values)[.timeEnd], "event_form_error_time_end".localized)

        XCTAssertTrue(EventFormValidator.errors(for: .schedule, values: validValues()).isEmpty)
    }

    func testPastDateIsIgnoredWhenNotChecked() {
        var values = validValues()
        values.day = calendar.date(byAdding: .day, value: -2, to: Date())
        var context = EventFormValidationContext()
        context.checkPastDates = false
        XCTAssertTrue(EventFormValidator.errors(for: .schedule, values: values, context: context).isEmpty)
    }

    func testRecurrenceHasNoErrorMessage() {
        // « Récurrence non choisie » n'est pas implémenté : « Juste une fois » est la valeur par défaut.
        XCTAssertEqual(EventFormValues().recurrence, .once)
        XCTAssertNil(EventFormValidator.errors(for: .schedule, values: validValues())[.date])
    }

    func testLocationErrors() {
        var values = validValues()
        values.latitude = nil
        values.longitude = nil
        values.googlePlaceId = nil
        XCTAssertEqual(EventFormValidator.errors(for: .location, values: values)[.address], "event_form_error_address".localized)

        values = validValues()
        values.isOnline = true
        values.onlineUrl = "http://zoom.us/j/123"
        XCTAssertEqual(EventFormValidator.errors(for: .location, values: values)[.onlineUrl], "event_form_error_link".localized)
        values.onlineUrl = "https://zoom.us/j/123"
        XCTAssertNil(EventFormValidator.errors(for: .location, values: values)[.onlineUrl])
        values.onlineUrl = "https://"
        XCTAssertNotNil(EventFormValidator.errors(for: .location, values: values)[.onlineUrl])
    }

    func testUnchangedOnlineLinkDoesNotBlockEdition() {
        var values = validValues()
        values.isOnline = true
        values.onlineUrl = "zoom.us/j/123"
        var context = EventFormValidationContext()
        context.unchangedOnlineUrl = "zoom.us/j/123"
        XCTAssertNil(EventFormValidator.errors(for: .location, values: values, context: context)[.onlineUrl])
    }

    func testPlaceLimitZeroIsRejected() {
        var values = validValues()
        values.hasPlaceLimit = true
        values.placeLimit = 0
        XCTAssertEqual(EventFormValidator.errors(for: .location, values: values)[.placeLimit], "event_form_error_places".localized)
        values.placeLimit = 1
        XCTAssertNil(EventFormValidator.errors(for: .location, values: values)[.placeLimit])
    }

    func testCategoriesAndGroups() {
        var values = validValues()
        values.interests = []
        XCTAssertEqual(EventFormValidator.errors(for: .categories, values: values)[.categories], "event_form_error_category".localized)
        // Zéro groupe : valide.
        XCTAssertTrue(EventFormValidator.errors(for: .groups, values: values).isEmpty)
    }

    func testFirstInvalidStep() {
        XCTAssertNil(EventFormValidator.firstInvalidStep(values: validValues()))
        var values = validValues()
        values.day = calendar.date(byAdding: .day, value: -1, to: Date())
        XCTAssertEqual(EventFormValidator.firstInvalidStep(values: values), .schedule)
    }

    // MARK: - Stepper de places

    func testPlaceLimitStepper() {
        let store = EventFormStore(values: validValues())
        XCTAssertFalse(store.values.hasPlaceLimit)
        store.incrementPlaceLimit()
        XCTAssertTrue(store.values.hasPlaceLimit)
        XCTAssertEqual(store.values.placeLimit, 1)
        store.incrementPlaceLimit()
        XCTAssertEqual(store.values.placeLimit, 2)
        store.decrementPlaceLimit()
        store.decrementPlaceLimit()
        XCTAssertFalse(store.values.hasPlaceLimit)
        XCTAssertEqual(store.values.placeLimit, 0)
    }

    // MARK: - Cartes fauteuil / famille

    func testGoingOnlineResetsWheelchair() {
        let store = EventFormStore(values: validValues())
        store.update { $0.isWheelchairAccessible = true; $0.isFamilyFriendly = true }
        store.setOnline(true)
        XCTAssertFalse(store.values.isWheelchairAccessible)
        XCTAssertTrue(store.values.isFamilyFriendly)
    }

    func testAccessibilityCardsAreSerialized() {
        var values = validValues()
        values.isWheelchairAccessible = true
        values.isFamilyFriendly = true

        var metadata = values.makeEvent().dictionaryForWS()["metadata"] as? [String: Any]
        XCTAssertEqual(metadata?["pmr"] as? Bool, true)
        XCTAssertEqual(metadata?["kids_friendly"] as? Bool, true)

        let initial = validValues()
        metadata = values.makeEditing(eventId: 1, initial: initial).dictionaryForWS()["metadata"] as? [String: Any]
        XCTAssertEqual(metadata?["pmr"] as? Bool, true)
        XCTAssertEqual(metadata?["kids_friendly"] as? Bool, true)

        // Inchangées : absentes du body d'édition.
        let same = values.makeEditing(eventId: 1, initial: values).dictionaryForWS()
        XCTAssertNil(same["metadata"])
    }

    func testPmrIsFalseWhenOnline() {
        var values = validValues()
        values.isOnline = true
        values.onlineUrl = "https://zoom.us/j/123"
        values.isWheelchairAccessible = true
        values.isFamilyFriendly = true
        var metadata = values.makeEvent().dictionaryForWS()["metadata"] as? [String: Any]
        XCTAssertEqual(metadata?["pmr"] as? Bool, false)
        XCTAssertEqual(metadata?["kids_friendly"] as? Bool, true)

        // Édition : le store remet la carte à false en passant en ligne.
        var initial = validValues()
        initial.isWheelchairAccessible = true
        values.isWheelchairAccessible = false
        metadata = values.makeEditing(eventId: 1, initial: initial).dictionaryForWS()["metadata"] as? [String: Any]
        XCTAssertEqual(metadata?["pmr"] as? Bool, false)
    }

    func testMetadataDecodesAccessibilityWithDefaults() throws {
        let full = try JSONDecoder().decode(EventMetadata.self, from: Data(#"{"pmr":true,"kids_friendly":true}"#.utf8))
        XCTAssertTrue(full.pmr)
        XCTAssertTrue(full.kidsFriendly)
        let empty = try JSONDecoder().decode(EventMetadata.self, from: Data(#"{"pmr":null}"#.utf8))
        XCTAssertFalse(empty.pmr)
        XCTAssertFalse(empty.kidsFriendly)
    }

    func testEditionPrefillsAccessibilityFromMetadata() {
        var event = Event()
        var md = EventMetadata()
        md.pmr = true
        md.kidsFriendly = true
        event.metadata = md
        let values = EventFormValues(event: event)
        XCTAssertTrue(values.isWheelchairAccessible)
        XCTAssertTrue(values.isFamilyFriendly)
    }

    func testReservedFemaleIsSentOnCreationAndWhenChangedOnEdition() {
        var values = validValues()
        values.isReservedFemale = false
        var metadata = values.makeEvent().dictionaryForWS()["metadata"] as? [String: Any]
        XCTAssertEqual(metadata?["reserved_female"] as? Bool, false)

        let initial = values
        values.isReservedFemale = true
        let editing = values.makeEditing(eventId: 1, initial: initial).dictionaryForWS()
        metadata = editing["metadata"] as? [String: Any]
        XCTAssertEqual(metadata?["reserved_female"] as? Bool, true)
    }

    // MARK: - Création

    func testOnlineCreationSendsLinkAndNoAddress() {
        var values = validValues()
        values.isOnline = true
        values.onlineUrl = "https://zoom.us/j/123"
        let dict = values.makeEvent().dictionaryForWS()
        XCTAssertEqual(dict["online"] as? Bool, true)
        XCTAssertEqual(dict["event_url"] as? String, "https://zoom.us/j/123")
        XCTAssertEqual(dict["latitude"] as? Int, 0)
        let metadata = dict["metadata"] as? [String: Any]
        XCTAssertEqual(metadata?["google_place_id"] as? String, "")
    }

    func testCreationRecurrence() {
        var values = validValues()
        values.recurrence = .every2Weeks
        XCTAssertEqual(values.makeEvent().dictionaryForWS()["recurrency"] as? Int, 14)
    }

    // MARK: - Modification (seuls les champs modifiés sont envoyés)

    func testEditionWithoutChangeSendsOnlyGroups() {
        let values = validValues()
        let dict = values.makeEditing(eventId: 42, initial: values).dictionaryForWS()
        XCTAssertEqual(Set(dict.keys), ["neighborhood_ids"])
    }

    func testEditionSendsOnlyChangedFields() {
        let initial = validValues()
        var values = initial
        values.title = "Nouveau titre"
        values.recurrence = .week
        let dict = values.makeEditing(eventId: 42, initial: initial).dictionaryForWS()
        XCTAssertEqual(dict["title"] as? String, "Nouveau titre")
        XCTAssertEqual(dict["recurrency"] as? Int, 7)
        XCTAssertNil(dict["description"])
        XCTAssertNil(dict["latitude"])
    }

    func testEditionKeepsGroups() {
        var initial = validValues()
        initial.groups = [EventNeighborhood(id: 7, name: "Groupe")]
        let dict = initial.makeEditing(eventId: 42, initial: initial).dictionaryForWS()
        XCTAssertEqual(dict["neighborhood_ids"] as? [Int], [7])
    }

    // MARK: - Brouillon local

    private func makeDefaults() -> UserDefaults {
        let name = "EventFormTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        addTeardownBlock { defaults.removePersistentDomain(forName: name) }
        return defaults
    }

    func testDraftRoundTripKeepsAccessibilityCards() {
        let defaults = makeDefaults()
        var values = validValues()
        values.isWheelchairAccessible = true
        values.isFamilyFriendly = true
        values.groups = [EventNeighborhood(id: 3, name: "Les voisins")]

        EventDraftStore.save(EventFormDraft(values: values, pageIndex: 2), userId: 12, defaults: defaults)
        let restored = EventDraftStore.load(userId: 12, defaults: defaults)
        XCTAssertEqual(restored?.values, values)
        XCTAssertEqual(restored?.pageIndex, 2)
    }

    func testDraftIsPerUserAndDeletable() {
        let defaults = makeDefaults()
        EventDraftStore.save(EventFormDraft(values: validValues(), pageIndex: 0), userId: 1, defaults: defaults)
        XCTAssertNotNil(EventDraftStore.load(userId: 1, defaults: defaults))
        XCTAssertNil(EventDraftStore.load(userId: 2, defaults: defaults))

        // Un seul brouillon par utilisateur : le second remplace le premier.
        var other = validValues()
        other.title = "Autre"
        EventDraftStore.save(EventFormDraft(values: other, pageIndex: 1), userId: 1, defaults: defaults)
        XCTAssertEqual(EventDraftStore.load(userId: 1, defaults: defaults)?.values.title, "Autre")

        EventDraftStore.delete(userId: 1, defaults: defaults)
        XCTAssertNil(EventDraftStore.load(userId: 1, defaults: defaults))
    }

    func testUnreadableDraftIsDropped() {
        let defaults = makeDefaults()
        defaults.set(Data("pas du json".utf8), forKey: EventDraftStore.key(for: 5))
        XCTAssertNil(EventDraftStore.load(userId: 5, defaults: defaults))
        XCTAssertNil(defaults.data(forKey: EventDraftStore.key(for: 5)))
    }

    func testObsoleteDraftIsRevalidated() {
        // Brouillon enregistré avec une date qui est ensuite devenue passée.
        var values = validValues()
        values.day = calendar.date(byAdding: .day, value: -3, to: Date())
        let defaults = makeDefaults()
        EventDraftStore.save(EventFormDraft(values: values, pageIndex: 3), userId: 9, defaults: defaults)
        let restored = EventDraftStore.load(userId: 9, defaults: defaults)!
        XCTAssertEqual(EventFormValidator.firstInvalidStep(values: restored.values), .schedule)
    }

    // MARK: - Chargement des conteneurs (sans lancer l'app)

    private func makeContainer<T: EventFormContainerViewController>(_ identifier: String, as type: T.Type) -> T {
        let storyboard = UIStoryboard(name: StoryboardName.eventCreate, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier) as! T
        vc.loadViewIfNeeded()
        vc.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        vc.view.layoutIfNeeded()
        return vc
    }

    func testCreateContainerLoadsAndNavigates() {
        let vc = makeContainer("eventCreateVCMain", as: EventCreateMainViewController.self)
        XCTAssertEqual(vc.currentPageIndex, 0)
        XCTAssertEqual(vc.pageViewController?.currentPage, .step(.presentation))

        // Etape 1 vide : « Continuer » reste sur l'étape et affiche les erreurs sous les champs.
        vc.action_next(self)
        XCTAssertEqual(vc.currentPageIndex, 0)
        XCTAssertNotNil(vc.formStore.errors[.title])
        XCTAssertNotNil(vc.formStore.errors[.photo])

        // Les erreurs disparaissent quand les champs sont corrigés.
        vc.formStore.update { $0.title = "Un titre" }
        XCTAssertNil(vc.formStore.errors[.title])

        vc.formStore.values = validValues()
        for expected in 1...EventCreateStep.count {
            vc.action_next(self)
            XCTAssertEqual(vc.currentPageIndex, expected)
        }
        XCTAssertEqual(vc.pageViewController?.currentPage, .preview)

        vc.action_back(self)
        XCTAssertEqual(vc.pageViewController?.currentPage, .step(.groups))
    }

    func testEditContainerLoadsWithRecurrentEvent() {
        let storyboard = UIStoryboard(name: StoryboardName.eventCreate, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "eventEditVCMain") as! EventEditMainViewController
        var event = Event()
        event.uid = 42
        event.title = "Atelier"
        event.descriptionEvent = "Venez"
        event.imageId = 2
        vc.currentEvent = event
        vc.eventId = 42
        vc.hasRecurrency = true
        vc.loadViewIfNeeded()
        vc.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        vc.view.layoutIfNeeded()

        XCTAssertEqual(vc.formStore.values.title, "Atelier")
        XCTAssertEqual(vc.pageViewController?.currentPage, .step(.presentation))
        XCTAssertTrue(vc.isEdit())
        XCTAssertTrue(vc.hasCurrentRecurrency())
        XCTAssertFalse(vc.supportsDraft)
    }

    func testCreationDoesNotRestoreDraft() {
        let vc = EventCreateMainViewController()
        XCTAssertFalse(vc.supportsDraft)
    }
}
