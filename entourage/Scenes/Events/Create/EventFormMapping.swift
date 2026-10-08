//
//  EventFormMapping.swift
//  entourage
//
//  Passage entre les valeurs du formulaire et les modèles réseau (Event / EventEditing).
//
//  `isWheelchairAccessible` -> metadata.pmr (toujours false en ligne),
//  `isFamilyFriendly` -> metadata.kids_friendly.
//

import Foundation

private extension String {
    var trimmed: String { return trimmingCharacters(in: .whitespacesAndNewlines) }
}

extension EventFormValues {

    // MARK: Event -> valeurs

    /// - Parameter forDuplication: duplication d'un événement existant (création) :
    ///   les dates sont effacées et l'image existante est réutilisée comme `image_url`.
    init(event: Event, forDuplication: Bool = false) {
        self.init()
        title = event.title
        descriptionText = event.descriptionEvent ?? ""
        imageId = event.imageId
        imageDisplayUrl = event.getCurrentImageUrl ?? event.imageUrl
        if forDuplication && event.imageId == nil {
            // Les événements issus de l'API stockent l'image dans les URLs des métadonnées.
            entourageImageUrl = event.entourage_image_url ?? event.metadata?.portrait_url ?? event.metadata?.landscape_url
        }

        recurrence = event.recurrence
        if !forDuplication {
            let dates = event.getStartEndDate()
            if let start = dates.startDate {
                day = Calendar.current.startOfDay(for: start)
                startMinutes = EventFormStore.minutes(of: start)
            }
            if let end = dates.endDate {
                endMinutes = EventFormStore.minutes(of: end)
            }
        }

        isOnline = event.isOnline ?? false
        onlineUrl = event.onlineEventUrl ?? ""
        addressName = event.addressName ?? ""
        streetAddress = event.metadata?.street_address ?? ""
        googlePlaceId = event.metadata?.google_place_id
        latitude = event.location?.latitude
        longitude = event.location?.longitude

        let limit = event.metadata?.place_limit ?? 0
        hasPlaceLimit = limit > 0
        placeLimit = max(limit, 0)
        isReservedFemale = event.metadata?.reservedFemale ?? false
        isWheelchairAccessible = isOnline ? false : (event.metadata?.pmr ?? false)
        isFamilyFriendly = event.metadata?.kidsFriendly ?? false

        interests = event.interests ?? []
        otherInterestMessage = event.tagOtherMessage ?? ""
        groups = event.neighborhoods ?? []
    }

    // MARK: Valeurs -> création

    func makeEvent() -> Event {
        var event = Event()
        event.metadata = EventMetadata()

        event.title = title.trimmed
        event.descriptionEvent = descriptionText.trimmed
        event.imageId = imageId
        event.entourage_image_url = (entourageImageUrl ?? "").isEmpty ? nil : entourageImageUrl

        event.isOnline = isOnline
        if isOnline {
            event.onlineEventUrl = onlineUrl.trimmed
            event.location = nil
            event.addressName = nil
            event.metadata?.street_address = ""
            event.metadata?.google_place_id = nil
        }
        else {
            event.onlineEventUrl = nil
            event.location = EventLocation(latitude: latitude, longitude: longitude)
            event.addressName = ""
            event.metadata?.street_address = streetAddress
            event.metadata?.google_place_id = googlePlaceId
        }

        event.startDate = startDate
        event.endDate = endDate
        event.recurrence = recurrence

        event.metadata?.place_limit = hasPlaceLimit ? placeLimit : 0
        event.metadata?.reservedFemale = isReservedFemale
        event.metadata?.pmr = isOnline ? false : isWheelchairAccessible
        event.metadata?.kidsFriendly = isFamilyFriendly

        event.interests = interests
        event.tagOtherMessage = (isOtherInterestSelected && !otherInterestMessage.trimmed.isEmpty) ? otherInterestMessage.trimmed : nil
        event.neighborhoods = groups
        return event
    }

    // MARK: Valeurs -> modification (seuls les champs modifiés sont envoyés)

    func makeEditing(eventId: Int, initial: EventFormValues) -> EventEditing {
        var editing = EventEditing()
        editing.metadata = EventMetadataEditing()
        // `EventMetadataEditing.place_limit` vaut 0 par défaut : sans ce reset, chaque modification
        // enverrait « 0 place » et supprimerait la limite existante.
        editing.metadata?.place_limit = nil
        editing.uid = eventId

        if title != initial.title { editing.title = title.trimmed }
        if descriptionText != initial.descriptionText { editing.descriptionEvent = descriptionText.trimmed }

        if let key = entourageImageUrl, !key.isEmpty, key != initial.entourageImageUrl {
            editing.entourage_image_url = key
        }
        else if let id = imageId, id != initial.imageId {
            editing.imageId = id
        }

        if recurrence != initial.recurrence { editing.recurrence = recurrence }

        if isOnline != initial.isOnline { editing.isOnline = isOnline }
        if isOnline {
            if isOnline != initial.isOnline || onlineUrl != initial.onlineUrl {
                editing.onlineEventUrl = onlineUrl.trimmed
            }
        }
        else {
            let placeChanged = latitude != initial.latitude
                || longitude != initial.longitude
                || googlePlaceId != initial.googlePlaceId
                || streetAddress != initial.streetAddress
            if isOnline != initial.isOnline || placeChanged {
                editing.location = EventLocation(latitude: latitude, longitude: longitude)
                editing.metadata?.place_name = ""
                editing.metadata?.street_address = streetAddress
                editing.metadata?.google_place_id = googlePlaceId
            }
        }

        if startDate != initial.startDate { editing.startDate = startDate }
        if endDate != initial.endDate { editing.endDate = endDate }

        if hasPlaceLimit != initial.hasPlaceLimit || placeLimit != initial.placeLimit {
            editing.metadata?.place_limit = hasPlaceLimit ? placeLimit : 0
        }
        if isReservedFemale != initial.isReservedFemale {
            editing.metadata?.reservedFemale = isReservedFemale
        }
        if isWheelchairAccessible != initial.isWheelchairAccessible {
            editing.metadata?.pmr = isOnline ? false : isWheelchairAccessible
        }
        if isFamilyFriendly != initial.isFamilyFriendly {
            editing.metadata?.kidsFriendly = isFamilyFriendly
        }

        if interests != initial.interests {
            editing.interests = interests
            if isOtherInterestSelected && !otherInterestMessage.trimmed.isEmpty {
                editing.tagOtherMessage = otherInterestMessage.trimmed
            }
        }

        // Toujours renseigné : `EventEditing.dictionaryForWS` enverrait sinon une liste vide
        // et retirerait l'événement de ses groupes.
        editing.neighborhoods = groups
        return editing
    }
}
