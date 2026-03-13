//
//  PreOnboardingModels.swift
//  entourage
//
//  Created by Clement entourage on 25/09/2025.
//

import Foundation

// MARK: - Salesforce

struct SalesforceEnterprise: Codable {
    let id: String?
    let name: String?
    let typeOrg: String? // "Entreprise", ...

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case typeOrg = "Type_org__c"
    }
}

struct SalesforceEvent: Codable {
    let id: String?
    let name: String?
    let codePostal: String?
    let isActive: Bool?
    let status: String?
    let startDate: String?           // ex: "2025-10-20"
    let startTimeZ: String?          // ex: "00:00:00.000Z"
    let endDate: String?             // ex: "2025-10-30"
    let endTimeZ: String?            // ex: "12:00:00.000Z"

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case codePostal = "Code_postal__c"
        case isActive = "IsActive"
        case status = "Status"
        case startDate = "StartDate"
        case startTimeZ = "Heure_de_d_but__c"
        case endDate = "EndDate"
        case endTimeZ = "Heure_de_fin__c"
    }
}

// MARK: - /home/metadata

struct HomeMetadata: Codable {
    let user: MetadataUser?
    let tags: MetadataTags?

    enum CodingKeys: String, CodingKey {
        case user
        case tags
    }
}

struct MetadataUser: Codable {
    let genders: [String: String]?              // ex: ["female":"Femme","male":"Homme","secret":"Non renseigné"]
    let discoverySources: [String: String]?     // ex: ["word_of_mouth":"Bouche à oreille", ... ]

    enum CodingKeys: String, CodingKey {
        case genders
        case discoverySources = "discovery_sources"
    }
}

struct MetadataTags: Codable {
    let sections: [TagSection]?
    let interests: [TagItem]?
    let involvements: [TagItem]?
    let concerns: [TagItem]?
    let signals: [TagItem]?
}

struct TagSection: Codable {
    let id: String?
    let name: String?
    let subname: String?
}

struct TagItem: Codable {
    let id: String?      // attention: parfois String (ex: "sport"), parfois Int dans d'autres endpoints
    let name: String?

    // Si un autre endpoint renvoie un Int, remplace par un enum ou une RawRepresentable custom.
}

