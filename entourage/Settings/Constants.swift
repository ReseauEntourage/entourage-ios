//
//  Constants.swift
//  entourage
//
//  Created by Jerome on 13/01/2022.
//

import Foundation

//Keys for Firebase
let kFirebaseDebugPlist = "GoogleService-Info-social.entourage.ios.beta"
let kFirebaseProdPlist = "GoogleService-Info"
let kUserAuthenticationLevelAuthenticated = "authenticated"

//Use for keychain storage
let kKeychainPhone = "entourage_user_phone"
let kKeychainPassword = "entourage_user_password"




//Constants
let PARIS_LAT = 48.856578
let PARIS_LON = 2.351828
let MAPVIEW_REGION_SPAN_X_METERS = 5000
let MAPVIEW_REGION_SPAN_Y_METERS = 5000
let MAPVIEW_REGION_LIGHT_SPAN_X_METERS = 800
let MAPVIEW_REGION_LIGHT_SPAN_Y_METERS = 800


struct StoryboardName {
    static let main = "Main"
    static let intro = "Intro"
    static let partnerDetails = "PartnerDetails"
    static let event = "Event"
    static let eventCreate = "Event_Create"
    static let eventMessage = "Event_Message"
    static let neighborhood = "Neighborhood"
    static let neighborhoodCreate = "Neighborhood_Create"
    static let neighborhoodReport = "Neighborhood_Report"
    static let neighborhoodMessage = "Neighborhood_Message"
    static let actions = "Actions"
    static let actionCreate = "Action_Create"
    
    static let solidarity = "GuideSolidarity"
    static let others = "Others"
    static let profileParams = "ProfileParams"
    static let userDetail = "UserDetail"
    
    static let messages = "Messages"
    
    static let onboarding = "Onboarding"
    
}
