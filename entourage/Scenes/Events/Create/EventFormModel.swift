//
//  EventFormModel.swift
//  entourage
//
//  Modèle du parcours de création / modification d'événement (refonte EN-9578) :
//  liste unique des étapes, valeurs du formulaire et règles de validation.
//  Aucune dépendance UIKit : tout ce fichier est testable unitairement.
//

import Foundation

// MARK: - Étapes -

/// Liste unique des étapes du parcours. Le nombre d'étapes (pagination, libellé
/// « Étape N sur X », notifications d'erreur) est TOUJOURS dérivé de cette liste.
enum EventCreateStep: CaseIterable {
    case presentation   // nom, description, photo
    case schedule       // date, heures, récurrence
    case location       // où et pour qui
    case categories     // catégories
    case groups         // partage dans des groupes

    static let all: [EventCreateStep] = EventCreateStep.allCases
    static var count: Int { all.count }

    /// Position 1-based dans la liste.
    var position: Int { (EventCreateStep.all.firstIndex(of: self) ?? 0) + 1 }

    var titleKey: String {
        switch self {
        case .presentation: return "event_form_step_presentation_title"
        case .schedule: return "event_form_step_schedule_title"
        case .location: return "event_form_step_location_title"
        case .categories: return "event_form_step_categories_title"
        case .groups: return "event_form_step_groups_title"
        }
    }
}

/// Une page du parcours : une étape, puis l'aperçu (hors compte « Étape N sur X »).
enum EventFormPage: Equatable {
    case step(EventCreateStep)
    case preview

    static let all: [EventFormPage] = EventCreateStep.all.map { EventFormPage.step($0) } + [.preview]
    static var count: Int { all.count }
    static var lastIndex: Int { count - 1 }

    var index: Int { EventFormPage.all.firstIndex(of: self) ?? 0 }
}

// MARK: - Champs (pour les erreurs sous le champ) -

enum EventFormField: Hashable {
    case title
    case description
    case photo
    case date
    case timeStart
    case timeEnd
    case address
    case onlineUrl
    case placeLimit
    case categories
    case otherCategory
}

// MARK: - Valeurs du formulaire -

/// Etat complet du formulaire. Sert aussi de format du brouillon local (Codable).
/// Les cartes « fauteuil » et « famille » vivent ici (formulaire, brouillon, aperçu)
/// mais ne sont JAMAIS envoyées au backend (voir EventFormMapping).
struct EventFormValues: Codable, Equatable {
    // Étape 1
    var title: String = ""
    var descriptionText: String = ""
    var imageId: Int? = nil
    /// Clé d'upload (photo personnalisée) ou URL envoyée comme `image_url`.
    var entourageImageUrl: String? = nil
    /// URL d'une photo déjà publiée / de la galerie, utilisée pour l'affichage.
    var imageDisplayUrl: String? = nil

    // Étape 2
    /// Jour choisi (début de journée).
    var day: Date? = nil
    /// Heures en minutes depuis minuit.
    var startMinutes: Int? = nil
    var endMinutes: Int? = nil
    var recurrence: EventRecurrence = .once

    // Étape 3
    var isOnline: Bool = false
    var onlineUrl: String = ""
    var addressName: String = ""
    var streetAddress: String = ""
    var googlePlaceId: String? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil
    var hasPlaceLimit: Bool = false
    var placeLimit: Int = 0
    var isWheelchairAccessible: Bool = false
    var isFamilyFriendly: Bool = false
    var isReservedFemale: Bool = false

    // Étape 4
    var interests: [String] = []
    var otherInterestMessage: String = ""

    // Étape 5
    var groups: [EventNeighborhood] = []

    // MARK: Dérivés

    var startDate: Date? { EventFormValues.date(day: day, minutes: startMinutes) }
    var endDate: Date? { EventFormValues.date(day: day, minutes: endMinutes) }

    var hasPhoto: Bool {
        return imageId != nil
            || !(entourageImageUrl ?? "").isEmpty
            || !(imageDisplayUrl ?? "").isEmpty
    }

    var hasPlace: Bool {
        return (latitude ?? 0) != 0 || !(googlePlaceId ?? "").isEmpty
    }

    var isOtherInterestSelected: Bool { interests.contains(Tag.tagOther) }

    private static func date(day: Date?, minutes: Int?) -> Date? {
        guard let day = day, let minutes = minutes else { return nil }
        return Calendar.current.date(bySettingHour: minutes / 60, minute: minutes % 60, second: 0, of: day)
    }
}

// MARK: - Validation -

struct EventFormValidationContext {
    var isEdit: Bool = false
    /// Faux en édition tant que la date n'a pas été modifiée par l'organisateur.
    var checkPastDates: Bool = true
    /// Lien en ligne déjà enregistré et non modifié (ne pas le bloquer en édition).
    var unchangedOnlineUrl: String? = nil
    var now: Date = Date()
}

/// Règles de validation uniques, partagées par la création et l'édition.
/// Les messages viennent de la banque du ticket EN-9578 (voir Localizable.strings).
enum EventFormValidator {

    static let httpsPrefix = "https://"

    static func errors(for step: EventCreateStep,
                       values v: EventFormValues,
                       context: EventFormValidationContext = EventFormValidationContext()) -> [EventFormField: String] {
        var errors = [EventFormField: String]()

        switch step {
        case .presentation:
            if v.title.trimmingCharacters(in: .whitespacesAndNewlines).count < ApplicationTheme.minGroupNameChars {
                errors[.title] = "event_form_error_title".localized
            }
            if v.descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).count <= 2 {
                errors[.description] = "event_form_error_description".localized
            }
            if !v.hasPhoto {
                errors[.photo] = "event_form_error_photo".localized
            }

        case .schedule:
            let calendar = Calendar.current
            if let day = v.day {
                if context.checkPastDates {
                    if day < calendar.startOfDay(for: context.now) {
                        errors[.date] = "event_form_error_date_past".localized
                    }
                    else if let start = v.startDate, start < context.now {
                        errors[.timeStart] = "event_form_error_date_past".localized
                    }
                }
                if v.startMinutes == nil {
                    errors[.timeStart] = errors[.timeStart] ?? "eventCreateInputErrorMandatory".localized
                }
                if v.endMinutes == nil {
                    errors[.timeEnd] = "eventCreateInputErrorMandatory".localized
                }
                else if let start = v.startMinutes, let end = v.endMinutes, end <= start {
                    errors[.timeEnd] = "event_form_error_time_end".localized
                }
            }
            else {
                errors[.date] = "event_form_error_date_empty".localized
            }

        case .location:
            if v.isOnline {
                let url = v.onlineUrl.trimmingCharacters(in: .whitespacesAndNewlines)
                let isUnchanged = context.unchangedOnlineUrl != nil && context.unchangedOnlineUrl == v.onlineUrl
                if !isUnchanged && !isValidOnlineUrl(url) {
                    errors[.onlineUrl] = "event_form_error_link".localized
                }
            }
            else if !v.hasPlace {
                errors[.address] = "event_form_error_address".localized
            }
            if v.hasPlaceLimit && v.placeLimit < 1 {
                errors[.placeLimit] = "event_form_error_places".localized
            }

        case .categories:
            if v.interests.isEmpty {
                errors[.categories] = "event_form_error_category".localized
            }
            else if v.isOtherInterestSelected && !context.isEdit
                        && v.otherInterestMessage.trimmingCharacters(in: .whitespacesAndNewlines).count < ApplicationTheme.minOthersCatChars {
                errors[.otherCategory] = "event_form_error_category_other".localized
            }

        case .groups:
            // Zéro, un ou plusieurs groupes : toujours valide.
            break
        }
        return errors
    }

    static func isValidOnlineUrl(_ url: String) -> Bool {
        let lowered = url.lowercased()
        return lowered.hasPrefix(httpsPrefix) && lowered.count > httpsPrefix.count
    }

    /// Première étape invalide, utilisée avant publication (brouillon obsolète, etc.).
    static func firstInvalidStep(values: EventFormValues,
                                 context: EventFormValidationContext = EventFormValidationContext()) -> EventCreateStep? {
        return EventCreateStep.all.first { !errors(for: $0, values: values, context: context).isEmpty }
    }
}
