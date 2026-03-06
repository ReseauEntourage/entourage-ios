//
//  OnboardingShared.swift
//  entourage
//
//  Created by Clement entourage on 14/10/2025.
//

import Foundation

enum UserType: Int {
    case neighbour = 1   // j’aide
    case alone     = 2   // je demande de l’aide
    case assos     = 3   // organisation
    case both      = 4   // j’aide et je demande
    case none      = 0

    func getGoalString() -> String {
        switch self {
        case .alone:     return "ask_for_help"
        case .neighbour: return "offer_help"
        case .assos:     return "organization"
        case .both:      return "ask_and_offer_help"
        case .none:      return ""
        }
    }
}
