//
//  ActionFormModel.swift
//  entourage
//
//  Modèle du parcours de création / modification d'une entraide, contribution ou demande
//  (change flux-creation-unifie) : liste des étapes (dynamique : l'étape de partage s'ajoute
//  ou se retire), valeurs du formulaire, règles de validation et passage vers le modèle `Action`.
//  Mêmes étapes, mêmes champs et mêmes requêtes qu'avant la refonte.
//  Aucune dépendance UIKit : testable unitairement.
//
//  Ordre des étapes (aligné sur Android, confirmé dans la storyboard `Action_Create` :
//  `createPhase2` = catégorie, `createPhase1` = titre + description, `createPhase3` = lieu,
//  `createPhase4` = partage) : catégorie, titre + description (image pour une contribution),
//  lieu, partage dans un groupe.
//

import Foundation

// MARK: - Étapes -

enum ActionCreateStep: Hashable {
    case category   // catégorie (section)
    case details    // titre, description (+ image pour une contribution)
    case location   // lieu
    case share      // partage dans le groupe (conditionnel)

    var titleKey: String {
        switch self {
        case .category: return "action_form_step_category_title"
        case .details: return "action_form_step_details_title"
        case .location: return "actionCellLocationTitle"
        case .share: return "share_request_title"
        }
    }

    /// Clé de la catégorie « partage de temps » : c'est elle qui déclenche l'étape de partage
    /// (comportement iOS conservé : `setNumberOfPage(4)` quand la section choisie est « social »).
    static let sharingSectionKey = "social"
}

/// Une page du parcours : une étape, puis l'aperçu (hors compte « Étape N sur X »).
enum ActionFormPage: Hashable {
    case step(ActionCreateStep)
    case preview
}

/// Liste des étapes, recalculée à chaque changement de catégorie. Le nombre d'étapes
/// (« Étape N sur X », progression, libellé du bouton) est TOUJOURS dérivé de cette liste.
enum ActionFormSteps {
    static func steps(for values: ActionFormValues) -> [ActionCreateStep] {
        var steps: [ActionCreateStep] = [.category, .details, .location]
        if values.hasShareStep {
            steps.append(.share)
        }
        return steps
    }

    static func pages(for values: ActionFormValues) -> [ActionFormPage] {
        return steps(for: values).map { ActionFormPage.step($0) } + [.preview]
    }
}

// MARK: - Champs (pour les erreurs sous le champ) -

enum ActionFormField: Hashable {
    case category
    case title
    case description
    case address
    case share
}

// MARK: - Valeurs du formulaire -

struct ActionFormValues: Equatable {
    // Catégorie
    var sectionKey: String? = nil
    /// La catégorie a été (re)choisie pendant ce parcours. En modification, l'étape de partage n'apparaît
    /// que dans ce cas (comme avant la refonte) ; la section n'est envoyée que si elle a été choisie.
    var sectionTouched: Bool = false

    // Titre, description, image
    var title: String = ""
    var descriptionText: String = ""
    /// URL de l'image déjà publiée (modification).
    var imageUrl: String? = nil
    /// Incrémenté à chaque nouvelle image choisie sur l'appareil (l'image elle-même vit dans le store).
    var newImageVersion: Int = 0

    // Lieu
    var placeName: String = ""
    var latitude: Double? = nil
    var longitude: Double? = nil

    // Partage dans un groupe (`nil` tant que l'utilisateur n'a pas répondu)
    var shareToGroup: Bool? = nil

    var hasPlace: Bool { return (latitude ?? 0) != 0 }
    var hasImage: Bool { return newImageVersion > 0 || !(imageUrl ?? "").isEmpty }
    var hasShareStep: Bool {
        return sectionKey == ActionCreateStep.sharingSectionKey && sectionTouched
    }
}

// MARK: - Validation -

struct ActionFormValidationContext {
    var isEdit: Bool = false
    /// En modification, on ne bloque pas une entraide ancienne qui n'avait pas de lieu.
    var initialHadPlace: Bool = true
    var initialHadSection: Bool = true
}

/// Règles de validation uniques, partagées par la création et la modification.
/// Titre : 2 caractères minimum ; description : 1 caractère minimum ; lieu : coordonnées non nulles.
enum ActionFormValidator {

    static let minTitleChars = 2
    static let minDescriptionChars = 1

    static func errors(for step: ActionCreateStep,
                       values v: ActionFormValues,
                       context: ActionFormValidationContext = ActionFormValidationContext()) -> [ActionFormField: String] {
        var errors = [ActionFormField: String]()

        switch step {
        case .category:
            if v.sectionKey == nil && (!context.isEdit || context.initialHadSection) {
                errors[.category] = "actionCreatePhase2_error".localized
            }

        case .details:
            if v.title.trimmingCharacters(in: .whitespacesAndNewlines).count < minTitleChars {
                errors[.title] = "action_form_error_title".localized
            }
            if v.descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).count < minDescriptionChars {
                errors[.description] = "action_form_error_description".localized
            }

        case .location:
            if !v.hasPlace && (!context.isEdit || context.initialHadPlace) {
                errors[.address] = "actionCreatePhase3_error".localized
            }

        case .share:
            if v.shareToGroup == nil {
                errors[.share] = "action_form_error_share".localized
            }
        }
        return errors
    }
}

// MARK: - Passage vers / depuis `Action` -

extension ActionFormValues {

    /// Valeurs d'une entraide existante (modification) : le formulaire est initialisé COMPLET.
    init(action: Action) {
        self.init()
        sectionKey = action.sectionName
        title = action.title ?? ""
        descriptionText = action.description ?? ""
        imageUrl = action.imageUrl
        placeName = action.metadata?.displayAddress ?? ""
        latitude = action.location?.latitude
        longitude = action.location?.longitude
    }

    /// Création : même corps qu'avant la refonte (titre, description, section, lieu).
    func makeAction() -> Action {
        var action = Action()
        action.title = title
        action.description = descriptionText
        action.sectionName = sectionKey
        if let latitude = latitude, let longitude = longitude {
            action.location = EventLocation(latitude: latitude, longitude: longitude)
        }
        return action
    }

    /// Modification : on repart de l'entraide existante (comme avant la refonte) ; la section n'est
    /// envoyée que si elle a été rechoisie.
    func makeEditing(from current: Action) -> Action {
        var action = current
        action.title = title
        action.description = descriptionText
        action.sectionName = sectionTouched ? sectionKey : nil
        if let latitude = latitude, let longitude = longitude {
            action.location = EventLocation(latitude: latitude, longitude: longitude)
        }
        return action
    }
}
