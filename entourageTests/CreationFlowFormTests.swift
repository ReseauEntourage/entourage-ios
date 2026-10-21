import XCTest
@testable import entourage

/// flux-creation-unifie : parcours de création / modification de groupe et d'entraide (logique pure, sans réseau).
final class CreationFlowFormTests: XCTestCase {

    // MARK: - Groupe

    private func validGroupValues() -> GroupFormValues {
        var values = GroupFormValues()
        values.name = "Les voisins de Paris 18"
        values.descriptionText = "Pour se rencontrer entre voisins"
        values.addressName = "Paris 18"
        values.latitude = 48.89
        values.longitude = 2.35
        values.interests = ["sport"]
        values.imageId = 4
        values.imageUrl = "https://example.org/photo.jpg"
        return values
    }

    func testGroupStepCountIsDerivedFromTheList() {
        XCTAssertEqual(GroupCreateStep.count, 3)
        XCTAssertEqual(GroupFormPage.count, GroupCreateStep.count + 1)
        XCTAssertEqual(GroupFormPage.all.last, .preview)
        XCTAssertEqual(GroupCreateStep.photo.position, GroupCreateStep.count)
    }

    func testGroupValidValuesHaveNoError() {
        XCTAssertNil(GroupFormValidator.firstInvalidStep(values: validGroupValues()))
    }

    func testGroupDetailsRequireNameDescriptionAndPlace() {
        let errors = GroupFormValidator.errors(for: .details, values: GroupFormValues())
        XCTAssertNotNil(errors[.name])
        XCTAssertNotNil(errors[.description])
        XCTAssertNotNil(errors[.address])

        var oneChar = validGroupValues()
        oneChar.name = "A"
        XCTAssertNotNil(GroupFormValidator.errors(for: .details, values: oneChar)[.name])
    }

    func testGroupInterestsRequireOneAndOtherNeedsAMessage() {
        var values = validGroupValues()
        values.interests = []
        XCTAssertNotNil(GroupFormValidator.errors(for: .interests, values: values)[.categories])

        values.interests = [Tag.tagOther]
        XCTAssertNotNil(GroupFormValidator.errors(for: .interests, values: values)[.otherInterest])
        values.otherInterestMessage = "Jardinage"
        XCTAssertTrue(GroupFormValidator.errors(for: .interests, values: values).isEmpty)
    }

    func testGroupPhotoIsRequiredButNotForAnOldGroupInEdit() {
        var values = validGroupValues()
        values.imageId = nil
        values.imageUrl = nil
        XCTAssertNotNil(GroupFormValidator.errors(for: .photo, values: values)[.photo])

        var context = GroupFormValidationContext()
        context.isEdit = true
        context.initialHadPhoto = false
        XCTAssertTrue(GroupFormValidator.errors(for: .photo, values: values, context: context).isEmpty)
    }

    func testGroupCreationBodyKeepsTheLegacyFields() {
        let dict = validGroupValues().makeNeighborhood().dictionaryForWS()
        XCTAssertEqual(dict["name"] as? String, "Les voisins de Paris 18")
        XCTAssertEqual(dict["description"] as? String, "Pour se rencontrer entre voisins")
        XCTAssertEqual(dict["place_name"] as? String, "Paris 18")
        XCTAssertEqual(dict["latitude"] as? Double, 48.89)
        XCTAssertEqual(dict["interests"] as? [String], ["sport"])
        XCTAssertEqual(dict["neighborhood_image_id"] as? Int, 4)
        // En création, seule l'identifiant de l'image est envoyé.
        XCTAssertNil(dict["image_url"])
        XCTAssertNil(dict["welcome_message"])
        XCTAssertNil(dict["other_interest"])
    }

    func testGroupEditingOnlySendsPlaceAndPhotoWhenChanged() {
        var initial = validGroupValues()
        initial.imageId = nil
        var edited = initial
        edited.name = "Nouveau nom"
        let unchanged = edited.makeEditing(id: 12, initial: initial).dictionaryForWS()
        XCTAssertEqual(unchanged["name"] as? String, "Nouveau nom")
        XCTAssertNil(unchanged["latitude"])
        XCTAssertNil(unchanged["image_url"])
        XCTAssertNil(unchanged["neighborhood_image_id"])

        edited.latitude = 45.0
        edited.longitude = 4.0
        edited.imageId = 9
        edited.imageUrl = "https://example.org/new.jpg"
        let changed = edited.makeEditing(id: 12, initial: initial).dictionaryForWS()
        XCTAssertEqual(changed["latitude"] as? Double, 45.0)
        XCTAssertEqual(changed["image_url"] as? String, "https://example.org/new.jpg")
        XCTAssertEqual(changed["neighborhood_image_id"] as? Int, 9)
    }

    // MARK: - Entraide

    private func validActionValues() -> ActionFormValues {
        var values = ActionFormValues()
        values.sectionKey = "services"
        values.sectionTouched = true
        values.title = "Aide aux courses"
        values.descriptionText = "Je peux aider"
        values.latitude = 48.85
        values.longitude = 2.35
        return values
    }

    func testActionStepsAreDerivedFromTheList() {
        var values = validActionValues()
        XCTAssertEqual(ActionFormSteps.steps(for: values), [.category, .details, .location])
        XCTAssertEqual(ActionFormSteps.pages(for: values).last, .preview)

        // « Partage de temps » : l'étape de partage s'ajoute, puis se retire si la catégorie change.
        values.sectionKey = "social"
        XCTAssertEqual(ActionFormSteps.steps(for: values), [.category, .details, .location, .share])
        values.sectionKey = "clothes"
        XCTAssertEqual(ActionFormSteps.steps(for: values), [.category, .details, .location])
    }

    func testActionShareStepIsNotAddedInEditUntilTheCategoryIsChosenAgain() {
        var values = validActionValues()
        values.sectionKey = "social"
        values.sectionTouched = false
        XCTAssertFalse(ActionFormSteps.steps(for: values).contains(.share))
    }

    func testActionValidationRules() {
        let empty = ActionFormValues()
        XCTAssertNotNil(ActionFormValidator.errors(for: .category, values: empty)[.category])
        XCTAssertNotNil(ActionFormValidator.errors(for: .details, values: empty)[.title])
        XCTAssertNotNil(ActionFormValidator.errors(for: .details, values: empty)[.description])
        XCTAssertNotNil(ActionFormValidator.errors(for: .location, values: empty)[.address])
        XCTAssertNotNil(ActionFormValidator.errors(for: .share, values: empty)[.share])

        var values = validActionValues()
        values.title = "Ab"          // titre : 2 caractères minimum
        values.descriptionText = "x" // description : 1 caractère minimum
        XCTAssertTrue(ActionFormValidator.errors(for: .details, values: values).isEmpty)
        values.title = "A"
        XCTAssertNotNil(ActionFormValidator.errors(for: .details, values: values)[.title])

        values.shareToGroup = false
        XCTAssertTrue(ActionFormValidator.errors(for: .share, values: values).isEmpty)
    }

    func testActionCreationBodyKeepsTheLegacyFields() {
        let dict = validActionValues().makeAction().dictionaryForWS()
        XCTAssertEqual(dict["title"] as? String, "Aide aux courses")
        XCTAssertEqual(dict["description"] as? String, "Je peux aider")
        XCTAssertEqual(dict["section"] as? String, "services")
        XCTAssertEqual((dict["location"] as? [String: Double])?["latitude"], 48.85)
        XCTAssertEqual(dict["recipient_consent_obtained"] as? Bool, true)
    }

    func testActionEditingOnlySendsTheSectionWhenChosenAgain() {
        var current = Action()
        current.id = 7
        current.sectionName = "services"
        var values = ActionFormValues(action: current)
        values.title = "Titre"
        values.descriptionText = "Description"
        values.latitude = 1
        values.longitude = 2
        XCTAssertNil(values.makeEditing(from: current).dictionaryForWS()["section"])

        values.selectSection("clothes")
        XCTAssertEqual(values.makeEditing(from: current).dictionaryForWS()["section"] as? String, "clothes")
    }
}

private extension ActionFormValues {
    mutating func selectSection(_ key: String) {
        sectionKey = key
        sectionTouched = true
    }
}
