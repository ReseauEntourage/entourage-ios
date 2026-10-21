//
//  EventFormComponents.swift
//  entourage
//
//  Les composants génériques des étapes vivent dans `FormFlow/FormFlowComponents.swift`.
//  Ce fichier ne garde que ce qui dépend des étapes de l'événement.
//

import SwiftUI

extension FormFlowStepHeader {
    /// En-tête d'une étape de l'événement : « Étape N sur X » dérivé de `EventCreateStep.all`.
    init(step: EventCreateStep) {
        self.init(position: step.position, count: EventCreateStep.count, titleKey: step.titleKey)
    }
}
