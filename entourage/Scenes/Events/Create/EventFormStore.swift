//
//  EventFormStore.swift
//  entourage
//
//  Etat observable du formulaire d'événement (une instance par conteneur de
//  création ou de modification) et brouillon local de création.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - Store -

final class EventFormStore: ObservableObject {

    @Published var values: EventFormValues {
        didSet { onValuesChange?() }
    }

    /// Erreurs affichées sous les champs de l'étape courante.
    @Published var errors: [EventFormField: String] = [:]

    /// Photo personnalisée choisie sur l'appareil (affichage uniquement, jamais dans le brouillon).
    @Published var localPhoto: UIImage? = nil
    @Published var isUploadingPhoto = false

    /// Appelé après chaque modification des valeurs (le conteneur revalide l'étape).
    var onValuesChange: (() -> Void)?

    init(values: EventFormValues = EventFormValues()) {
        self.values = values
    }

    // MARK: Helpers

    func update(_ change: (inout EventFormValues) -> Void) {
        var copy = values
        change(&copy)
        values = copy
    }

    func binding<T>(_ keyPath: WritableKeyPath<EventFormValues, T>) -> Binding<T> {
        return Binding<T>(
            get: { self.values[keyPath: keyPath] },
            set: { newValue in self.update { $0[keyPath: keyPath] = newValue } }
        )
    }

    func error(for field: EventFormField) -> String? {
        return errors[field]
    }

    // MARK: Étape 1

    func setGalleryImage(_ image: EventImage) {
        // Paysage d'abord (affiché en bandeau) : le portrait agrandi serait pixellisé.
        let url = [image.url_image_landscape, image.url_image_portrait].compactMap { $0 }.first { !$0.isEmpty }
        update {
            $0.imageId = image.id
            $0.entourageImageUrl = nil
            $0.imageDisplayUrl = url
        }
        localPhoto = nil
    }

    func setUploadedImage(key: String, image: UIImage) {
        update {
            $0.imageId = nil
            $0.entourageImageUrl = key
            $0.imageDisplayUrl = nil
        }
        localPhoto = image
    }

    func clearPhoto() {
        update {
            $0.imageId = nil
            $0.entourageImageUrl = nil
            $0.imageDisplayUrl = nil
        }
        localPhoto = nil
    }

    // MARK: Étape 2

    func setDay(_ date: Date) {
        update { $0.day = Calendar.current.startOfDay(for: date) }
    }

    static func minutes(of date: Date) -> Int {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
    }

    // MARK: Étape 3

    /// Passage présentiel / en ligne. En ligne, la carte fauteuil disparaît et sa valeur est annulée.
    func setOnline(_ online: Bool) {
        update {
            $0.isOnline = online
            if online { $0.isWheelchairAccessible = false }
        }
    }

    func setPlace(name: String, street: String, placeId: String?, latitude: Double?, longitude: Double?) {
        update {
            $0.addressName = name
            $0.streetAddress = street
            $0.googlePlaceId = placeId
            $0.latitude = latitude
            $0.longitude = longitude
        }
    }

    func clearPlace() {
        update {
            $0.addressName = ""
            $0.streetAddress = ""
            $0.googlePlaceId = nil
            $0.latitude = nil
            $0.longitude = nil
        }
    }

    /// Stepper de places : « Non » -> 1 -> 2 ... ; depuis 1, « − » revient à « Non ».
    func incrementPlaceLimit() {
        update {
            if !$0.hasPlaceLimit {
                $0.hasPlaceLimit = true
                $0.placeLimit = 1
            }
            else if $0.placeLimit < EventFormStore.maxPlaceLimit {
                $0.placeLimit += 1
            }
        }
    }

    func decrementPlaceLimit() {
        update {
            guard $0.hasPlaceLimit else { return }
            if $0.placeLimit <= 1 {
                $0.hasPlaceLimit = false
                $0.placeLimit = 0
            }
            else {
                $0.placeLimit -= 1
            }
        }
    }

    static let maxPlaceLimit = 9999

    // MARK: Étape 4

    func toggleInterest(_ key: String) {
        update {
            if let index = $0.interests.firstIndex(of: key) {
                $0.interests.remove(at: index)
                if key == Tag.tagOther { $0.otherInterestMessage = "" }
            }
            else {
                $0.interests.append(key)
            }
        }
    }

    // MARK: Étape 5

    func isGroupSelected(_ id: Int) -> Bool {
        return values.groups.contains { $0.id == id }
    }

    func toggleGroup(id: Int, name: String) {
        update {
            if let index = $0.groups.firstIndex(where: { $0.id == id }) {
                $0.groups.remove(at: index)
            }
            else {
                $0.groups.append(EventNeighborhood(id: id, name: name))
            }
        }
    }
}

// MARK: - Brouillon local -

struct EventFormDraft: Codable {
    var version: Int = 1
    var values: EventFormValues
    /// Index (dans `EventFormPage.all`) de la page où l'utilisateur a enregistré.
    var pageIndex: Int
    var savedAt: Date = Date()
}

/// Brouillon local persistant : un seul par utilisateur, création uniquement.
/// Ecrit uniquement au clic sur « Enregistrer », supprimé après une publication réussie.
enum EventDraftStore {

    static func key(for userId: Int) -> String {
        return "entourage.event_create_draft.\(userId)"
    }

    static var currentUserId: Int? {
        guard let user = UserDefaults.currentUser else { return nil }
        return user.sid
    }

    static func save(_ draft: EventFormDraft, userId: Int, defaults: UserDefaults = .standard) {
        guard let data = try? JSONEncoder().encode(draft) else { return }
        defaults.set(data, forKey: key(for: userId))
    }

    static func load(userId: Int, defaults: UserDefaults = .standard) -> EventFormDraft? {
        guard let data = defaults.data(forKey: key(for: userId)) else { return nil }
        guard let draft = try? JSONDecoder().decode(EventFormDraft.self, from: data) else {
            // Brouillon illisible (format obsolète) : on le supprime plutôt que de bloquer la création.
            defaults.removeObject(forKey: key(for: userId))
            return nil
        }
        return draft
    }

    static func delete(userId: Int, defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: key(for: userId))
    }
}
