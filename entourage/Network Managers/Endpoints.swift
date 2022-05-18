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
let kAPIDeleteUser = "users/me?token=%@"
let kAPIUpdateUserPartner = "partners/join_request?token=%@"
let kAPIUpdateAccountPartner = "users/me/following?token=%@"
let kAPIReportUser = "users/%@/report?token=%@"
let kAPIGetDetailUser = "users/%@?token=%@"
let kAPIGetAllAssociations = "partners?token=%@"
let kAPIGetDetailAssociation = "partners/%d?token=%@"
let kAPIAppInfoPushToken = "applications?token=%@"
let kAPIPois = "pois"
let kAPIMetadatas = "home/metadata?token=%@"

//group / neighborhood
let kAPINeighborhoods = "neighborhoods?token=%@"
let kAPIGetDetailNeighborhood = "neighborhoods/%@?token=%@"
let kAPIUpdateNeighborhood = "neighborhoods/%@?token=%@"
let kAPIGetneighborhoodImages = "neighborhood_images?token=%@"
let kAPIGetMyNeighborhoods = "users/%@/neighborhoods?token=%@&page=%d&per=%d"
let kAPISearchNeighborhoods = "neighborhoods?token=%@&q=%@"
let kAPIGetSuggestNeighborhoods = "neighborhoods?token=%@&page=%d&per=%d"
let kAPIJoinNeighborhood = "neighborhoods/%@/users?token=%@"
let kAPILeaveNeighborhood = "neighborhoods/%@/users/%@?token=%@"
let kAPIReportNeighborhood = "neighborhoods/%@/report?token=%@"
let kAPIGetNeighborhoodUsers = "neighborhoods/%@/users?token=%@"
let kAPIGetNeighborhoodPostsMessage = "neighborhoods/%@/chat_messages?token=%@&page=%d&per=%d"

let kAPIPostNeighborhoodPostMessage = "neighborhoods/%@/chat_messages?token=%@"
let kAPIGetNeighborhoodMessages = "neighborhoods/%@/chat_messages/%@/comments?token=%@"


//Amazon S3
let API_URL_USER_PREPARE_AVATAR_UPLOAD = "users/me/presigned_avatar_upload.json?token=%@"


//WebLink
let emailContact = "contact@entourage.social"
let GDS_INFO_ALERT_WEB_LINK = "https://soliguide.fr"
let ENTOURAGE_BITLY_LINK = "https://bit.ly/applientourage"
let PROPOSE_STRUCTURE_URL = "%@links/propose-poi/redirect?token=%@"
let ENTOURAGE_WEB_URL = "https://www.entourage.social"
let APPSTORE_URL = "https://apps.apple.com/fr/app/entourage-reseau-solidaire/id1072244410"
let AMBASSADOR_URL = "https://www.entourage.social/devenir-ambassadeur/?utm_source=app&utm_medium=app"
let CHARTE_URL = "https://blog.entourage.social/charte-ethique-grand-public/"
let MENU_LICENSES_URL = "https://www.entourage.social"
//Menu Links
let BASE_MENU_ABOUT = "links/%@/redirect?token=%@"
let MENU_ABOUT_SLUG_SUGGEST = "suggestion"
let MENU_ABOUT_SLUG_FAQ = "faq"
let MENU_ABOUT_SLUG_GIFT = "donation"
let MENU_ABOUT_SLUG_CGU = "terms"
let MENU_ABOUT_SLUG_PRIVACY = "privacy-policy"

