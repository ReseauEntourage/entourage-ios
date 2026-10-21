//
//  GroupFormModel.swift
//  entourage
//
//  Modèle du parcours de création / modification d'un groupe (change flux-creation-unifie) :
//  liste unique des étapes, valeurs du formulaire, règles de validation et passage vers le
//  modèle `Neighborhood` envoyé à l'API. Mêmes étapes, mêmes champs et même corps de requête
//  qu'avant la refonte ; seuls les messages d'erreur sont désormais propres à chaque champ.
//  Aucune dépendance UIKit : testable unitairement.
//

import Foundation

// MARK: - Étapes -

/// Liste unique des étapes du parcours. Le nombre d'étapes (progression, « Étape N sur X »)
/// est TOUJOURS dérivé de cette liste.
enum GroupCreateStep: CaseIterable {
    case details    // nom, description, lieu
    case interests  // centres d'intérêt
    case photo      // photo (+ message de bienvenue facultatif)

    static let all: [GroupCreateStep] = GroupCreateStep.allCases
    static var count: Int { all.count }

    /// Position 1-based dans la liste.
    var position: Int { (GroupCreateStep.all.firstIndex(of: self) ?? 0) + 1 }

    var titleKey: String {
        switch self {
        case .details: return "group_form_step_details_title"
        case .interests: return "group_form_step_interests_title"
        case .photo: return "group_form_step_photo_title"
        }
    }
}

/// Une page du parcours : une étape, puis l'aperçu (hors compte « Étape N sur X »).
enum GroupFormPage: Equatable {
    case step(GroupCreateStep)
    case preview

    static let all: [GroupFormPage] = GroupCreateStep.all.map { GroupFormPage.step($0) } + [.preview]
    static var count: Int { all.count }
    static var lastIndex: Int { count - 1 }

    var index: Int { GroupFormPage.all.firstIndex(of: self) ?? 0 }
}

// MARK: - Champs (pour les erreurs sous le champ) -

enum GroupFormField: Hashable {
    case name
    case description
    case address
    case categories
    case otherInterest
    case photo
}

// MARK: - Valeurs du formulaire -

struct GroupFormValues: Equatable {
    // Étape 1
    var name: String = ""
    var descriptionText: String = ""
    var addressName: String = ""
    var latitude: Double? = nil
    var longitude: Double? = nil
    var googlePlaceId: String? = nil

    // Étape 2
    var interests: [String] = []
    var otherInterestMessage: String = ""

    // Étape 3
    var welcomeMessage: String = ""
    var imageId: Int? = nil
    /// URL de la photo choisie (galerie) ou déjà publiée, utilisée pour l'affichage.
    var imageUrl: String? = nil

    // MARK: Dérivés

    var hasPlace: Bool {
        return (latitude ?? 0) != 0 || !(googlePlaceId ?? "").isEmpty
    }

    var hasPhoto: Bool {
        return imageId != nil || !(imageUrl ?? "").isEmpty
    }

    var isOtherInterestSelected: Bool { interests.contains(Tag.tagOther) }

    /// Valeurs du lieu seules (pour savoir si le lieu a été modifié en édition).
    fileprivate var placeSignature: [String] {
        return [addressName, String(latitude ?? 0), String(longitude ?? 0), googlePlaceId ?? ""]
    }
}

// MARK: - Validation -

struct GroupFormValidationContext {
    var isEdit: Bool = false
    /// En édition, on ne bloque pas un groupe ancien qui n'avait pas de lieu ou de photo.
    var initialHadPlace: Bool = true
    var initialHadPhoto: Bool = true
}

/// Règles de validation uniques, partagées par la création et l'édition.
/// Mêmes règles qu'avant la refonte : nom 2 caractères minimum, description non vide, lieu,
/// au moins un intérêt (précision obligatoire pour « autre »), photo.
enum GroupFormValidator {

    static func errors(for step: GroupCreateStep,
                       values v: GroupFormValues,
                       context: GroupFormValidationContext = GroupFormValidationContext()) -> [GroupFormField: String] {
        var errors = [GroupFormField: String]()

        switch step {
        case .details:
            if v.name.trimmingCharacters(in: .whitespacesAndNewlines).count < ApplicationTheme.minGroupNameChars {
                errors[.name] = "group_form_error_name".localized
            }
            if v.descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errors[.description] = "group_form_error_description".localized
            }
            if !v.hasPlace && (!context.isEdit || context.initialHadPlace) {
                errors[.address] = "group_form_error_address".localized
            }

        case .interests:
            if v.interests.isEmpty {
                errors[.categories] = "neighborhoodCreatePhase2_error".localized
            }
            else if v.isOtherInterestSelected && !context.isEdit
                        && v.otherInterestMessage.trimmingCharacters(in: .whitespacesAndNewlines).count < ApplicationTheme.minOthersCatChars {
                errors[.otherInterest] = "neighborhoodCreatePhase2_others_error".localized
            }

        case .photo:
            if !v.hasPhoto && (!context.isEdit || context.initialHadPhoto) {
                errors[.photo] = "group_form_error_photo".localized
            }
        }
        return errors
    }

    /// Première étape invalide, utilisée avant l'envoi.
    static func firstInvalidStep(values: GroupFormValues,
                                 context: GroupFormValidationContext = GroupFormValidationContext()) -> GroupCreateStep? {
        return GroupCreateStep.all.first { !errors(for: $0, values: values, context: context).isEmpty }
    }
}

// MARK: - Passage vers / depuis `Neighborhood` -

extension GroupFormValues {

    /// Valeurs d'un groupe existant (édition) : le formulaire est initialisé COMPLET.
    init(neighborhood: Neighborhood) {
        self.init()
        name = neighborhood.name
        descriptionText = neighborhood.aboutGroup ?? ""
        welcomeMessage = neighborhood.welcomeMessage ?? ""
        addressName = neighborhood.address?.displayAddress ?? ""
        latitude = neighborhood.address?.latitude
        longitude = neighborhood.address?.longitude
        googlePlaceId = neighborhood.address?.google_place_id
        interests = neighborhood.interests ?? []
        imageUrl = neighborhood.image_url
    }

    /// Création : même corps qu'avant la refonte (`neighborhood_image_id`, pas d'`image_url`).
    func makeNeighborhood() -> Neighborhood {
        var group = Neighborhood()
        group.name = name
        group.aboutGroup = descriptionText
        group.welcomeMessage = welcomeMessage
        group.address = makeAddress(forEdit: false)
        group.interests = interests
        group.tagOtherMessage = isOtherInterestSelected ? otherInterestMessage : nil
        group.neighborhood_image_id = imageId
        return group
    }

    /// Modification : même corps qu'avant la refonte (lieu et photo envoyés seulement s'ils ont changé).
    func makeEditing(id: Int, initial: GroupFormValues) -> Neighborhood {
        var group = Neighborhood()
        group.uid = id
        group.name = name
        group.aboutGroup = descriptionText
        group.welcomeMessage = welcomeMessage
        if placeSignature != initial.placeSignature {
            group.address = makeAddress(forEdit: true)
        }
        if !interests.isEmpty {
            group.interests = interests
        }
        if imageId != nil || (imageUrl != initial.imageUrl && !(imageUrl ?? "").isEmpty) {
            group.image_url = imageUrl
            group.neighborhood_image_id = imageId
        }
        return group
    }

    private func makeAddress(forEdit: Bool) -> Address? {
        if let latitude = latitude, let longitude = longitude, latitude != 0 || longitude != 0 {
            return Address(displayAddress: addressName, latitude: latitude, longitude: longitude)
        }
        if let placeId = googlePlaceId, !placeId.isEmpty {
            // Création : nom + identifiant Google ; modification : identifiant seul (comme avant).
            return Address(displayAddress: forEdit ? nil : addressName, google_place_id: placeId)
        }
        return nil
    }
}
