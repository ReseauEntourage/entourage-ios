//
//  ActionFormStore.swift
//  entourage
//
//  Etat observable du formulaire d'entraide (une instance par conteneur de création ou de
//  modification), sur le modèle d'`EventFormStore`.
//

import Foundation
import UIKit
import SwiftUI

final class ActionFormStore: ObservableObject {

    @Published var values: ActionFormValues {
        didSet { onValuesChange?() }
    }

    /// Erreurs affichées sous les champs de l'étape courante.
    @Published var errors: [ActionFormField: String] = [:]

    /// Image choisie sur l'appareil (contribution) : affichage et envoi à la publication.
    @Published var localImage: UIImage? = nil

    /// Nom du groupe par défaut, cité dans l'étape de partage.
    @Published var defaultGroupName: String = ""

    /// Appelé après chaque modification des valeurs (le conteneur revalide l'étape et recalcule la liste d'étapes).
    var onValuesChange: (() -> Void)?

    init(values: ActionFormValues = ActionFormValues()) {
        self.values = values
    }

    /// Etapes du parcours, dérivées des valeurs (l'étape de partage s'ajoute ou se retire).
    var steps: [ActionCreateStep] { return ActionFormSteps.steps(for: values) }

    func update(_ change: (inout ActionFormValues) -> Void) {
        var copy = values
        change(&copy)
        values = copy
    }

    func binding<T>(_ keyPath: WritableKeyPath<ActionFormValues, T>) -> Binding<T> {
        return Binding<T>(
            get: { self.values[keyPath: keyPath] },
            set: { newValue in self.update { $0[keyPath: keyPath] = newValue } }
        )
    }

    func selectSection(_ key: String) {
        update {
            $0.sectionKey = key
            $0.sectionTouched = true
        }
    }

    func setImage(_ image: UIImage?) {
        localImage = image
        update { $0.newImageVersion = image == nil ? 0 : $0.newImageVersion + 1 }
    }

    func setPlace(name: String, latitude: Double?, longitude: Double?) {
        update {
            $0.placeName = name
            $0.latitude = latitude
            $0.longitude = longitude
        }
    }
}
