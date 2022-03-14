//
//  Endpoints.swift
//  entourage
//
//  Created by Jerome on 12/01/2022.
//

import Foundation


//API
let kAPICreateAccount = "users"
let kAPILogin = "login"
let kAPIResendCode = "users/me/code.json"
let kAPIChangePhone = "users/request_phone_change"
let kAPIUpdateAddressPrimary = "users/me/addresses/1?token=%@"
let kAPIUpdateAddressSecondary = "users/me/addresses/2?token=%@"
let kAPIUpdateUser = "users/me.json?token=%@"
let kAPIUpdateUserPartner = "partners/join_request?token=%@"
let kAPIUpdateAccountPartner = "users/me/following?token=%@"
let kAPIGetDetailUser = "users/%@?token=%@"
let kAPIGetAllAssociations = "partners?token=%@"
let kAPIGetDetailAssociation = "partners/%d?token=%@"
let kAPIAppInfoPushToken = "applications?token=%@"
let kAPIPois = "pois"
let kAPIMetadatas = "home/metadata?token=%@"
//Amazon S3
let API_URL_USER_PREPARE_AVATAR_UPLOAD = "users/me/presigned_avatar_upload.json?token=%@"


//WebLink
let emailContact = "contact@entourage.social"
let GDS_INFO_ALERT_WEB_LINK = "https://soliguide.fr"
let ENTOURAGE_BITLY_LINK = "https://bit.ly/applientourage"
let PROPOSE_STRUCTURE_URL = "%@links/propose-poi/redirect?token=%@"
let ENTOURAGE_WEB_URL = "https://www.entourage.social"

