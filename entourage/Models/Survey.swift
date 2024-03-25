//
//  Survey.swift
//  entourage
//
//  Created by Clement entourage on 15/03/2024.
//

import Foundation

// Modèle pour encapsuler les réponses d'un sondage.
struct SurveyResponsesWrapper: Codable {
    let responses: [Bool]
}

// Modèle pour un utilisateur ayant répondu à un sondage.
struct SurveyResponseUser: Codable {
    let id: Int
    let lang: String
    let displayName: String
    let avatarUrl: String?
    let communityRoles: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, lang, displayName = "display_name", avatarUrl = "avatar_url", communityRoles = "community_roles"
    }
}

// Modèle pour représenter la réponse d'un sondage, incluant les utilisateurs ayant répondu.
struct SurveyResponse: Codable {
    let users: [SurveyResponseUser]
}

// Wrapper pour la liste des réponses d'un sondage.
struct SurveyResponsesListWrapper: Codable {
    let responses: [[SurveyResponseUser]]
    
    enum CodingKeys: String, CodingKey {
        case responses = "survey_responses"
    }
}

// Modèle pour le message d'un chat contenant un sondage.
struct ChatMessageSurvey: Codable {
    let content: String
    let surveyAttributes: SurveyAttributes?
    
    enum CodingKeys: String, CodingKey {
        case content, surveyAttributes = "survey_attributes"
    }
}

// Attributs d'un sondage, incluant les choix et si plusieurs réponses sont possibles.
struct SurveyAttributes: Codable {
    let choices: [String]
    let multiple: Bool
}
