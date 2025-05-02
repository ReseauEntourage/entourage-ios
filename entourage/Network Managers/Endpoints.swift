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
let kpiGetCluster = "pois/clusters"

let kAPIMetadatas = "home/metadata?token=%@"

let kAPIUnreadCount = "users/unread?token=%@"

//group / neighborhood
let kAPINeighborhoods = "neighborhoods?token=%@"
let kAPIGetDetailNeighborhood = "neighborhoods/%@?token=%@"
let kAPIUpdateNeighborhood = "neighborhoods/%@?token=%@"
let kAPIGetneighborhoodImages = "neighborhood_images?token=%@"
let kAPIGetMyNeighborhoods = "users/%@/neighborhoods?token=%@&page=%d&per=%d"
let kAPIGetMyFilteredNeighborhoods = "users/%@/neighborhoods?token=%@&page=%d&per=%d&travel_distance=%.2f&latitude=%.6f&longitude=%.6f&interest_list=%@"
let kAPISearchNeighborhoods = "neighborhoods?token=%@&q=%@"
let kAPIGetSuggestNeighborhoods = "neighborhoods?token=%@&page=%d&per=%d"
let kAPIGetSuggestFilteredNeighborhoods = "neighborhoods?token=%@&page=%d&per=%d&travel_distance=%.2f&latitude=%.6f&longitude=%.6f&interest_list=%@"
let kAPIGetSuggestFilteredNoInterestsNeighborhoods = "neighborhoods?token=%@&page=%d&per=%d&travel_distance=%.2f&latitude=%.6f&longitude=%.6f"
let kAPIGetSuggestFilteredNoInterestsMyNeighborhoods = "users/%@/neighborhoods?token=%@&page=%d&per=%d&travel_distance=%.2f&latitude=%.6f&longitude=%.6f"
let kAPIJoinNeighborhood = "neighborhoods/%@/users?token=%@"
let kAPILeaveNeighborhood = "neighborhoods/%@/users/%@?token=%@"
let kAPIReportNeighborhood = "neighborhoods/%@/report?token=%@"
let kAPIGetNeighborhoodUsers = "neighborhoods/%@/users?token=%@"
let kAPIGetNeighborhoodPostsMessage = "neighborhoods/%@/chat_messages?token=%@&page=%d&per=%d&image_size=high"
let kAPINeighborhoodsSearch = "neighborhoods?token=%@&page=%d&per=%d&q=%@"
let kAPIGetMyNeighborhoodsSearch = "users/%@/neighborhoods?token=%@&page=%d&per=%d&q=%@"

let kAPIPostNeighborhoodPostMessage = "neighborhoods/%@/chat_messages?token=%@"
let kAPIGetNeighborhoodMessages = "neighborhoods/%@/chat_messages/%@/comments?token=%@"
let kAPIReportPostNeighborhood = "neighborhoods/%@/chat_messages/%@/report?token=%@"
let kAPIReportPostCommentNeighborhood = "neighborhoods/%@/chat_messages/%@/report?token=%@"
let kAPIGetNeighborhoodPostMessage = "neighborhoods/%@/chat_messages/%@?token=%@&image_size=high"
let kAPIDeleteNeigborhoodPostMessage = "neighborhoods/%d/chat_messages/%d?token=%@"
let kAPIPostReactionGroupPost = "neighborhoods/%d/chat_messages/%d/reactions?token=%@"
let kAPIDeleteReactionGroupPost = "neighborhoods/%d/chat_messages/%d/reactions?token=%@"
let kAPIGetDetailsReactionGroupPost = "neighborhoods/%d/chat_messages/%d/reactions/users?token=%@"


//Amazon S3
let API_URL_USER_PREPARE_AVATAR_UPLOAD = "users/me/presigned_avatar_upload.json?token=%@"
let API_URL_NEIGHBORHOOD_PREPARE_IMAGE_POST_UPLOAD = "neighborhoods/%@/chat_messages/presigned_upload?token=%@"
let API_URL_EVENT_PREPARE_IMAGE_POST_UPLOAD = "outings/%@/chat_messages/presigned_upload?token=%@"
let API_URL_CONTRIB_PREPARE_IMAGE_UPLOAD = "contributions/presigned_upload?token=%@"

//Home
let kAPIHomeSummary = "home/summary?token=%@"
let kAPIHomeResources = "resources?token=%@"
let kAPIHomeInitialResources = "resources/home?token=%@"
let kAPIHomeGetResource = "resources/%@?token=%@"
let kAPIHomeResourceRead = "resources/%d/users?token=%@"
let kAPIHomeWebRecoRead = "webviews/url?url=%@&token=%@"

//Event
let kAPIEventImages = "entourage_images?token=%@"
let kAPIEventDetail = "outings/%@?token=%@"
let kAPIEventCreate = "outings?token=%@"
let kAPIEventGetAllDiscover = "outings?token=%@&page=%d&per=%d&period=future"
let kAPIEventGetAllFilteredDiscover = "outings?token=%@&page=%d&per=%d&period=future&travel_distance=%.2f&latitude=%.6f&longitude=%.6f&interest_list=%@"
let kAPIEventGetAllFilteredDiscoverNoInterest = "outings?token=%@&page=%d&per=%d&period=future&travel_distance=%.2f&latitude=%.6f&longitude=%.6f"
let kAPIEventGetAllForUser = "users/%@/outings?token=%@&page=%d&per=%d"
let kAPIEventGetAllForMe = "users/me/outings?token=%@&page=%d&per=%d"
let kAPIEventEdit = "outings/%d?token=%@"
let kAPIEventEditWithRecurrency = "outings/%d/batch_update?token=%@"
let kAPIEventGetAllForNeighborhood = "neighborhoods/%d/outings?token=%@"
let kAPIGetEventPostsMessage = "outings/%@/chat_messages?token=%@&page=%d&per=%d"
let kAPIJoinEvent = "outings/%@/users?token=%@"
let kAPILeaveEvent = "outings/%@/users/%@?token=%@"
let kAPIGetEventUsers = "outings/%@/users?token=%@"
let kAPIEventCancel = "outings/%d?token=%@"
let kAPIEventCancelWithRecurrency = "outings/%d/batch_update?token=%@"
let kAPISearchEvents = "outings?token=%@&page=%d&per=%d&q=%@"
let kAPISearchMyEvents = "users/%@/outings?token=%@&page=%d&per=%d&q=%@"

let kAPIReportEvent = "outings/%@/report?token=%@"
let kAPIReportPostEvent = "outings/%@/chat_messages/%@/report?token=%@"
let kAPIReportPostCommentEvent = "outings/%@/chat_messages/%@/report?token=%@"
let kAPIPostOutingPostMessage = "outings/%@/chat_messages?token=%@"
let kAPIGetOutingMessages = "outings/%@/chat_messages/%@/comments?token=%@"
let kAPIGetOutingPostMessage = "outings/%@/chat_messages/%@?token=%@&image_size=high"
let kAPIDeleteEventPostMessage = "outings/%d/chat_messages/%d?token=%@"
let kAPIPostReactionEventPost = "outings/%d/chat_messages/%d/reactions?token=%@"
let kAPIDeleteReactionEventPost = "outings/%d/chat_messages/%d/reactions?token=%@"
let kAPIGetDetailsReactionEventPost = "outings/%d/chat_messages/%d/reactions/users?token=%@"
let kAPIConfirmParticipation = "outings/%@/users/confirm?token=%@"
let kAPIGetMyFilteredOutings = "users/%@/outings?token=%@&page=%d&per=%d&travel_distance=%.2f&latitude=%.6f&longitude=%.6f&interest_list=%@"

//Actions
let kAPIGetContrib = "contributions/%@?token=%@"
let kAPIGetSolicitation = "solicitations/%@?token=%@"
let kAPIContribCreate = "contributions?token=%@"
let kAPISolicitationCreate = "solicitations?token=%@"
let kAPIContribUpdate = "contributions/%d?token=%@"
let kAPISolicitationUpdate = "solicitations/%d?token=%@"

let kAPIActionGetAllContribs = "contributions?token=%@&page=%d&per=%d"
let kAPIActionGetAllContribsWithFilter = "contributions?token=%@&page=%d&per=%d&travel_distance=%.2f&latitude=%.6f&longitude=%.6f&section_list=%@"
let kAPIActionGetAllContribsWitherSearch = "contributions?token=%@&page=%d&per=%d&q=%@"

let kAPIActionGetAllSolicitations = "solicitations?token=%@&page=%d&per=%d"
let kAPIActionGetAllSolicitationsWithFilter = "solicitations?token=%@&page=%d&per=%d&travel_distance=%.2f&latitude=%.6f&longitude=%.6f&section_list=%@"
let kAPIActionGetAllSolicitationsWithSearch = "solicitations?token=%@&page=%d&per=%d&q=%@"

let kAPIActionGetAllForMe = "users/me/actions?token=%@&page=%d&per=%d"

let kAPIReportContrib = "contributions/%@/report?token=%@"
let kAPIReportSolicitation = "solicitations/%@/report?token=%@"

//Messaging
let kAPIConversationGetAllConversations = "conversations?token=%@&page=%d&per=%d"
let kAPIGetConversationDetailMessages = "conversations/%@/chat_messages?token=%@&page=%d&per=%d"
let kAPIPostConversationMessage = "conversations/%@/chat_messages?token=%@"
let kAPIConversationPostCreateConversation = "conversations?token=%@"
let kAPIConversationReportConversation = "conversations/%@/report?token=%@"
let kAPIConversationQuitConversation = "conversations/%@/users?token=%@"
let kAPIConversationGetDetailConversation = "conversations/%@?token=%@"
let kAPIAddUserToConversation = "conversations/%@/users?token=%@"


//Chat message
let kAPIChatMessageDelete = "/chat_messages/%d?token=%@"

//Block / unblock user
let kAPIBlockUser = "user_blocked_users/?token=%@"
let kAPIUnBlockUsers = "user_blocked_users/?token=%@"
let kAPIGetBlockedUsers = "user_blocked_users?token=%@"
let kAPIGetIsBlockedUser = "user_blocked_users/%d?token=%@"
let kAPIGetDeleteMessageInConv = "conversations/%d/chat_messages/%d"


//WebLink
let emailContact = "https://www.entourage.social/contact/"
let GDS_INFO_ALERT_WEB_LINK = "https://soliguide.fr"
let ENTOURAGE_BITLY_LINK = "https://bit.ly/applientourage"
let PROPOSE_STRUCTURE_URL = "%@links/propose-poi/redirect?token=%@"
let ENTOURAGE_WEB_URL = "https://www.entourage.social"
let APPSTORE_URL = "https://apps.apple.com/fr/app/entourage-reseau-solidaire/id1072244410"
let AMBASSADOR_URL = "https://www.entourage.social/devenir-ambassadeur/?utm_source=app&utm_medium=app"
let CHARTE_URL = "https://www.entourage.social/blog/charte-ethique-entourage-local/"
let MENU_LICENSES_URL = "https://www.entourage.social"
let PARTNER_URL = "https://www.entourage.social/mecenes-et-partenaires/"
let MENU_SUGGEST_URL = "https://entourage-asso.typeform.com/to/NRhT8vmj"

//Menu Links
let BASE_MENU_ABOUT = "links/%@/redirect?token=%@"
let MENU_ABOUT_SLUG_SUGGEST = "suggestion"
let MENU_ABOUT_SLUG_FAQ = "faq"
let MENU_ABOUT_SLUG_GIFT = "donation"
let MENU_ABOUT_SLUG_CGU = "terms"
let MENU_ABOUT_SLUG_PRIVACY = "privacy-policy"

//Notifs in app
let kAPINotifsGetCount = "inapp_notifications/count?token=%@"
let kAPINotifsGetNotifs = "inapp_notifications?token=%@&page=%d&per=%d"
let kAPINotifsMarkRead = "inapp_notifications/%d?token=%@"
let kAPINotifsGetPermissions = "notification_permissions?token=%@"
let kAPINotifsPostPermissions = "notification_permissions?token=%@"

// Survey Responses for Groups
let kAPIPostSurveyResponseGroup = "neighborhoods/%d/chat_messages/%d/survey_responses?token=%@"
let kAPIGetSurveyResponsesForGroup = "neighborhoods/%d/chat_messages/%d/survey_responses?token=%@"
let kAPIDeleteSurveyResponseForGroup = "neighborhoods/%d/chat_messages/%d/survey_responses?token=%@"
let kAPICreateSurveyInGroup = "neighborhoods/%d/chat_messages?token=%@"

// Survey Responses for Events
let kAPIPostSurveyResponseEvent = "outings/%d/chat_messages/%d/survey_responses?token=%@"
let kAPIGetSurveyResponsesForEvent = "outings/%d/chat_messages/%d/survey_responses?token=%@"
let kAPIDeleteSurveyResponseForEvent = "outings/%d/chat_messages/%d/survey_responses?token=%@"
let kAPICreateSurveyInEvent = "outings/%d/chat_messages?token=%@"

