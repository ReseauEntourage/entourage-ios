// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let agirIcnAide = ImageAsset(name: "agir_icn_aide")
  internal static let agirIcnDon = ImageAsset(name: "agir_icn_don")
  internal static let agirIcnEvent = ImageAsset(name: "agir_icn_event")
  internal static let agirIcnMaraude = ImageAsset(name: "agir_icn_maraude")
  internal static let agirIcnWeb = ImageAsset(name: "agir_icn_web")
  internal static let agirImageHelp = ImageAsset(name: "agir_image_help")
  internal static let askForHelpEvent = ImageAsset(name: "ask_for_help_event")
  internal static let askForHelpEventPoi = ImageAsset(name: "ask_for_help_event_poi")
  internal static let askForHelpInfo = ImageAsset(name: "ask_for_help_info")
  internal static let askForHelpMatHelp = ImageAsset(name: "ask_for_help_mat_help")
  internal static let askForHelpOther = ImageAsset(name: "ask_for_help_other")
  internal static let askForHelpResource = ImageAsset(name: "ask_for_help_resource")
  internal static let askForHelpSkill = ImageAsset(name: "ask_for_help_skill")
  internal static let askForHelpSocial = ImageAsset(name: "ask_for_help_social")
  internal static let contributionEvent = ImageAsset(name: "contribution_event")
  internal static let contributionInfo = ImageAsset(name: "contribution_info")
  internal static let contributionMatHelp = ImageAsset(name: "contribution_mat_help")
  internal static let contributionOther = ImageAsset(name: "contribution_other")
  internal static let contributionResource = ImageAsset(name: "contribution_resource")
  internal static let contributionSkill = ImageAsset(name: "contribution_skill")
  internal static let contributionSocial = ImageAsset(name: "contribution_social")
  internal static let distributiveTourIcon = ImageAsset(name: "distributive_tour_icon")
  internal static let medicalTourIcon = ImageAsset(name: "medical_tour_icon")
  internal static let socialTourIcon = ImageAsset(name: "social_tour_icon")
  internal static let arrowForExpandableMenu = ImageAsset(name: "arrowForExpandableMenu")
  internal static let poweredByGoogle = ImageAsset(name: "PoweredByGoogle")
  internal static let about = ImageAsset(name: "about")
  internal static let arrowGrey = ImageAsset(name: "arrowGrey")
  internal static let back = ImageAsset(name: "back")
  internal static let bg = ImageAsset(name: "bg")
  internal static let calendar = ImageAsset(name: "calendar")
  internal static let centerLocation = ImageAsset(name: "center-location")
  internal static let friends = ImageAsset(name: "friends")
  internal static let guide = ImageAsset(name: "guide")
  internal static let handshake = ImageAsset(name: "handshake")
  internal static let icActionRecordSound = ImageAsset(name: "ic_action_record_sound")
  internal static let icActionStopSound = ImageAsset(name: "ic_action_stop_sound")
  internal static let icClose = ImageAsset(name: "ic_close")
  internal static let lock = ImageAsset(name: "lock")
  internal static let mapPlaceholderBg = ImageAsset(name: "map-placeholder-bg")
  internal static let mapPin = ImageAsset(name: "map_pin")
  internal static let neighborhood = ImageAsset(name: "neighborhood")
  internal static let next = ImageAsset(name: "next")
  internal static let outing = ImageAsset(name: "outing")
  internal static let parameters = ImageAsset(name: "parameters")
  internal static let privateCircle = ImageAsset(name: "private-circle")
  internal static let questionChat = ImageAsset(name: "question_chat")
  internal static let record = ImageAsset(name: "record")
  internal static let s = ImageAsset(name: "s")
  internal static let search = ImageAsset(name: "search")
  internal static let unlock = ImageAsset(name: "unlock")
  internal static let whiteSearch = ImageAsset(name: "whiteSearch")
  internal static let slice = ImageAsset(name: "slice")
  internal static let announcementCardPlaceholder = ImageAsset(name: "announcementCardPlaceholder")
  internal static let award = ImageAsset(name: "award")
  internal static let contacts = ImageAsset(name: "contacts")
  internal static let rescue = ImageAsset(name: "rescue")
  internal static let location = ImageAsset(name: "location")
  internal static let distibutive = ImageAsset(name: "distibutive")
  internal static let distibutiveActive = ImageAsset(name: "distibutiveActive")
  internal static let medical = ImageAsset(name: "medical")
  internal static let medicalActive = ImageAsset(name: "medicalActive")
  internal static let pause = ImageAsset(name: "pause")
  internal static let play = ImageAsset(name: "play")
  internal static let social = ImageAsset(name: "social")
  internal static let socialActive = ImageAsset(name: "socialActive")
  internal static let stop = ImageAsset(name: "stop")
  internal static let bubbleDiscussion = ImageAsset(name: "bubbleDiscussion")
  internal static let bubbleDiscussionGrey = ImageAsset(name: "bubbleDiscussionGrey")
  internal static let chat = ImageAsset(name: "chat")
  internal static let chatActive = ImageAsset(name: "chatActive")
  internal static let information = ImageAsset(name: "information")
  internal static let informationActive = ImageAsset(name: "informationActive")
  internal static let more = ImageAsset(name: "more")
  internal static let share = ImageAsset(name: "share")
  internal static let userPlus = ImageAsset(name: "userPlus")
  internal static let mic = ImageAsset(name: "mic")
  internal static let report = ImageAsset(name: "report")
  internal static let addressBookSquare = ImageAsset(name: "addressBookSquare")
  internal static let phoneSquare = ImageAsset(name: "phoneSquare")
  internal static let _24HActive = ImageAsset(name: "24HActive")
  internal static let _24HInactive = ImageAsset(name: "24HInactive")
  internal static let _24HSelected = ImageAsset(name: "24HSelected")
  internal static let filterEat = ImageAsset(name: "filter_eat")
  internal static let filterHeal = ImageAsset(name: "filter_heal")
  internal static let filterSocial = ImageAsset(name: "filter_social")
  internal static let filters = ImageAsset(name: "filters")
  internal static let filtersBlue = ImageAsset(name: "filtersBlue")
  internal static let friendlyTime = ImageAsset(name: "friendlyTime")
  internal static let geoloc = ImageAsset(name: "geoloc")
  internal static let invitationSquare = ImageAsset(name: "invitationSquare")
  internal static let activeButton = ImageAsset(name: "activeButton")
  internal static let joinButton = ImageAsset(name: "joinButton")
  internal static let userSmall = ImageAsset(name: "userSmall")
  internal static let users = ImageAsset(name: "users")
  internal static let carte = ImageAsset(name: "carte")
  internal static let carteSelected = ImageAsset(name: "carte_selected")
  internal static let list = ImageAsset(name: "list")
  internal static let listSelected = ImageAsset(name: "list_selected")
  internal static let arrowNewEntourages = ImageAsset(name: "arrowNewEntourages")
  internal static let heatZone = ImageAsset(name: "heatZone")
  internal static let heatZoneFinger = ImageAsset(name: "heatZoneFinger")
  internal static let newEntourages = ImageAsset(name: "newEntourages")
  internal static let plus = ImageAsset(name: "plus")
  internal static let tip = ImageAsset(name: "tip")
  internal static let code = ImageAsset(name: "code")
  internal static let logoWhiteEntourage = ImageAsset(name: "logoWhiteEntourage")
  internal static let mapPinSquare = ImageAsset(name: "mapPinSquare")
  internal static let nextFull = ImageAsset(name: "nextFull")
  internal static let nextOpacity70 = ImageAsset(name: "nextOpacity70")
  internal static let notificationsSquare = ImageAsset(name: "notificationsSquare")
  internal static let whitePhone = ImageAsset(name: "whitePhone")
  internal static let whiteUser = ImageAsset(name: "whiteUser")
  internal static let imgHello = ImageAsset(name: "img_hello")
  internal static let onboardPictoAide = ImageAsset(name: "onboard_picto_aide")
  internal static let onboardPictoAssignment = ImageAsset(name: "onboard_picto_assignment")
  internal static let onboardPictoAutre = ImageAsset(name: "onboard_picto_autre")
  internal static let onboardPictoCulture = ImageAsset(name: "onboard_picto_culture")
  internal static let onboardPictoInvestir = ImageAsset(name: "onboard_picto_investir")
  internal static let onboardPictoNotification = ImageAsset(name: "onboard_picto_notification")
  internal static let onboardPictoSearch = ImageAsset(name: "onboard_picto_search")
  internal static let profilVerfi = ImageAsset(name: "profil_verfi")
  internal static let icnNeighbourEntourer = ImageAsset(name: "icn_neighbour_entourer")
  internal static let icnNeighbourEvents = ImageAsset(name: "icn_neighbour_events")
  internal static let icnNeighbourGift = ImageAsset(name: "icn_neighbour_gift")
  internal static let icnNeighbourInfo = ImageAsset(name: "icn_neighbour_info")
  internal static let icnNeighbourInvestir = ImageAsset(name: "icn_neighbour_investir")
  internal static let onboardBtNext = ImageAsset(name: "onboard_bt_next")
  internal static let onboardBtPrevious = ImageAsset(name: "onboard_bt_previous")
  internal static let onboardPictoAlone = ImageAsset(name: "onboard_picto_alone")
  internal static let onboardPictoAsso = ImageAsset(name: "onboard_picto_asso")
  internal static let onboardPictoGeoloc = ImageAsset(name: "onboard_picto_geoloc")
  internal static let onboardPictoHelp = ImageAsset(name: "onboard_picto_help")
  internal static let icnSdfCircle = ImageAsset(name: "icn_sdf_circle")
  internal static let icnSdfEvents = ImageAsset(name: "icn_sdf_events")
  internal static let icnSdfHelp = ImageAsset(name: "icn_sdf_help")
  internal static let icnSdfHelp2 = ImageAsset(name: "icn_sdf_help2")
  internal static let icnSdfOrienter = ImageAsset(name: "icn_sdf_orienter")
  internal static let icnSdfQuestion = ImageAsset(name: "icn_sdf_question")
  internal static let icnSdfSearch = ImageAsset(name: "icn_sdf_search")
  internal static let introBg = ImageAsset(name: "intro-bg")
  internal static let pfpIntroSmallLogo = ImageAsset(name: "pfp-intro-small-logo")
  internal static let pfpIntroTopLogo = ImageAsset(name: "pfp-intro-top-logo")
  internal static let phone = ImageAsset(name: "phone")
  internal static let logoEntourageVerticale = ImageAsset(name: "Logo Entourage Verticale")
  internal static let logoMainSeul = ImageAsset(name: "Logo Main Seul")
  internal static let mosaic = ImageAsset(name: "Mosaic")
  internal static let controlSelected = ImageAsset(name: "control_selected")
  internal static let controlUnselected = ImageAsset(name: "control_unselected")
  internal static let preOnboard1 = ImageAsset(name: "pre_onboard_1")
  internal static let preOnboard2 = ImageAsset(name: "pre_onboard_2")
  internal static let preOnboard3 = ImageAsset(name: "pre_onboard_3")
  internal static let preOnboard4 = ImageAsset(name: "pre_onboard_4")
  internal static let preOnboardEvent = ImageAsset(name: "pre_onboard_event")
  internal static let sms = ImageAsset(name: "sms")
  internal static let user = ImageAsset(name: "user")
  internal static let welcome = ImageAsset(name: "welcome")
  internal static let arrowForMenu = ImageAsset(name: "arrowForMenu")
  internal static let blog = ImageAsset(name: "blog")
  internal static let broadcast = ImageAsset(name: "broadcast")
  internal static let chart = ImageAsset(name: "chart")
  internal static let goal = ImageAsset(name: "goal")
  internal static let heartNofillWhite = ImageAsset(name: "heartNofillWhite")
  internal static let mapPin = ImageAsset(name: "mapPin")
  internal static let mapPinWhite = ImageAsset(name: "mapPinWhite")
  internal static let menuBa = ImageAsset(name: "menu_ba")
  internal static let menuPhone = ImageAsset(name: "menu_phone")
  internal static let star = ImageAsset(name: "star")
  internal static let menuFacebook = ImageAsset(name: "menu_facebook")
  internal static let menuInstagram = ImageAsset(name: "menu_instagram")
  internal static let menuLink = ImageAsset(name: "menu_link")
  internal static let menuMail = ImageAsset(name: "menu_mail")
  internal static let menuTwitter = ImageAsset(name: "menu_twitter")
  internal static let backArrow = ImageAsset(name: "backArrow")
  internal static let backItem = ImageAsset(name: "backItem")
  internal static let icEntourage = ImageAsset(name: "ic_entourage")
  internal static let info = ImageAsset(name: "info")
  internal static let inviteplus = ImageAsset(name: "inviteplus")
  internal static let menu = ImageAsset(name: "menu")
  internal static let botEntourage = ImageAsset(name: "botEntourage")
  internal static let close = ImageAsset(name: "close")
  internal static let discussion = ImageAsset(name: "discussion")
  internal static let flag = ImageAsset(name: "flag")
  internal static let icNavigationGuide = ImageAsset(name: "ic_navigation_guide")
  internal static let icnPlusMapSolidarity = ImageAsset(name: "icn_plus_map_solidarity")
  internal static let logo = ImageAsset(name: "logo")
  internal static let whiteClose = ImageAsset(name: "whiteClose")
  internal static let addEvent = ImageAsset(name: "addEvent")
  internal static let addOptionWithShadow = ImageAsset(name: "addOptionWithShadow")
  internal static let addStructure = ImageAsset(name: "addStructure")
  internal static let closeNoShadow = ImageAsset(name: "closeNoShadow")
  internal static let closeOptionNoShadow = ImageAsset(name: "closeOptionNoShadow")
  internal static let closeOptionWithShadow = ImageAsset(name: "closeOptionWithShadow")
  internal static let closeShadow = ImageAsset(name: "closeShadow")
  internal static let create = ImageAsset(name: "create")
  internal static let createNoShadow = ImageAsset(name: "createNoShadow")
  internal static let badgeDefault = ImageAsset(name: "badgeDefault")
  internal static let cameraSquare = ImageAsset(name: "cameraSquare")
  internal static let layer = ImageAsset(name: "layer")
  internal static let layerPhoto = ImageAsset(name: "layer_photo")
  internal static let notVerified = ImageAsset(name: "notVerified")
  internal static let password = ImageAsset(name: "password")
  internal static let verified = ImageAsset(name: "verified")
  internal static let iconAaFacebook = ImageAsset(name: "icon-aa-facebook")
  internal static let iconAaTwitter = ImageAsset(name: "icon-aa-twitter")
  internal static let iconAaYoutube = ImageAsset(name: "icon-aa-youtube")
  internal static let shareNative = ImageAsset(name: "share_native")
  internal static let eat = ImageAsset(name: "eat")
  internal static let heal = ImageAsset(name: "heal")
  internal static let housing = ImageAsset(name: "housing")
  internal static let leaveGuideButton = ImageAsset(name: "leaveGuideButton")
  internal static let lookAfterYourself = ImageAsset(name: "lookAfterYourself")
  internal static let orientate = ImageAsset(name: "orientate")
  internal static let reinsertYourself = ImageAsset(name: "reinsertYourself")
  internal static let socialSg = ImageAsset(name: "social_sg")
  internal static let tel = ImageAsset(name: "tel")
  internal static let water = ImageAsset(name: "water")
  internal static let mapTab = ImageAsset(name: "map_tab")
  internal static let mapTabSelected = ImageAsset(name: "map_tab_selected")
  internal static let menuTab = ImageAsset(name: "menu_tab")
  internal static let menuTabSelected = ImageAsset(name: "menu_tab_selected")
  internal static let messagesTab = ImageAsset(name: "messages_tab")
  internal static let messagesTabSelected = ImageAsset(name: "messages_tab_selected")
  internal static let icAlimentary = ImageAsset(name: "ic_alimentary")
  internal static let icBareHands = ImageAsset(name: "ic_bare_hands")
  internal static let icCar = ImageAsset(name: "ic_car")
  internal static let icFeet = ImageAsset(name: "ic_feet")
  internal static let icMedical = ImageAsset(name: "ic_medical")
  internal static let poiCategory0 = ImageAsset(name: "poi_category-0")
  internal static let poiCategory1 = ImageAsset(name: "poi_category-1")
  internal static let poiCategory2 = ImageAsset(name: "poi_category-2")
  internal static let poiCategory3 = ImageAsset(name: "poi_category-3")
  internal static let poiCategory4 = ImageAsset(name: "poi_category-4")
  internal static let poiCategory5 = ImageAsset(name: "poi_category-5")
  internal static let poiCategory6 = ImageAsset(name: "poi_category-6")
  internal static let poiCategory7 = ImageAsset(name: "poi_category-7")
  internal static let poiCluster = ImageAsset(name: "poi_cluster")
  internal static let poiTransparentCategory1 = ImageAsset(name: "poi_transparent_category-1")
  internal static let poiTransparentCategory2 = ImageAsset(name: "poi_transparent_category-2")
  internal static let poiTransparentCategory3 = ImageAsset(name: "poi_transparent_category-3")
  internal static let poiTransparentCategory4 = ImageAsset(name: "poi_transparent_category-4")
  internal static let poiTransparentCategory5 = ImageAsset(name: "poi_transparent_category-5")
  internal static let poiTransparentCategory6 = ImageAsset(name: "poi_transparent_category-6")
  internal static let poiTransparentCategory7 = ImageAsset(name: "poi_transparent_category-7")
  internal static let pointer = ImageAsset(name: "pointer")
  internal static let rencontre = ImageAsset(name: "rencontre")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
}

internal extension ImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    Bundle(for: BundleToken.self)
  }()
}
// swiftlint:enable convenience_type
