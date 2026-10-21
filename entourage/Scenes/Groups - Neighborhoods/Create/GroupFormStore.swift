//
//  GroupFormStore.swift
//  entourage
//
//  Etat observable du formulaire de groupe (une instance par conteneur de création ou de
//  modification), sur le modèle d'`EventFormStore`.
//

import Foundation
import SwiftUI

final class GroupFormStore: ObservableObject {

    @Published var values: GroupFormValues {
        didSet { onValuesChange?() }
    }

    /// Erreurs affichées sous les champs de l'étape courante.
    @Published var errors: [GroupFormField: String] = [:]

    /// Appelé après chaque modification des valeurs (le conteneur revalide l'étape).
    var onValuesChange: (() -> Void)?

    init(values: GroupFormValues = GroupFormValues()) {
        self.values = values
    }

    func update(_ change: (inout GroupFormValues) -> Void) {
        var copy = values
        change(&copy)
        values = copy
    }

    func binding<T>(_ keyPath: WritableKeyPath<GroupFormValues, T>) -> Binding<T> {
        return Binding<T>(
            get: { self.values[keyPath: keyPath] },
            set: { newValue in self.update { $0[keyPath: keyPath] = newValue } }
        )
    }

    func setPlace(name: String, latitude: Double?, longitude: Double?, googlePlaceId: String?) {
        update {
            $0.addressName = name
            $0.latitude = latitude
            $0.longitude = longitude
            $0.googlePlaceId = googlePlaceId
        }
    }

    func setGalleryImage(_ image: NeighborhoodImage) {
        update {
            $0.imageId = image.uid
            $0.imageUrl = image.imageUrl
        }
    }

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
}
