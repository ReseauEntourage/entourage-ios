//
//  OnboardingDelegate.swift
//  entourage
//

import Foundation
import CoreLocation
import GooglePlaces

protocol OnboardingDelegate: AnyObject {
    func addUserInfos(
        firstname: String?,
        lastname: String?,
        countryCode: CountryCode,
        phone: String?,
        email: String?,
        consentEmail: Bool,
        gender: String?,
        howWeMet: String?,
        birthdate: String?,
        company: String?,
        event: String?
    )

    func sendCode(code: String)

    func addInfos(userType: UserType)

    func addPlace(
        currentlocation: CLLocationCoordinate2D?,
        currentLocationName: String?,
        googlePlace: GMSPlace?
    )

    func goMain()

    func requestNewcode()
}
