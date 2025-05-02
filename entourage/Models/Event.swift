//
//  Event.swift
//  entourage
//
//

import Foundation


struct Event:Codable {
    var uid:Int = 0
    var uuid:String = ""
    var uuid_v2:String = ""
    var title:String = ""
    var descriptionEvent:String? = nil
    
    var shareUrl:String? = nil
    var imageUrl:String? = nil
    var imageId:Int? = nil
    
    var isOnline:Bool? = false
    var onlineEventUrl:String? = nil
    
    var author:EventAuthor? = nil
    
    var location:EventLocation? = nil
    var distance:Double? = 0.0
    
    var metadata:EventMetadata? = nil
    
    var interests:[String]? = nil
    var tagOtherMessage:String? = nil
    
    var neighborhoods:[EventNeighborhood]? = nil
    
    var membersCount:Int? = nil
    
    var isMember:Bool? = false
    var posts:[PostMessage]? = nil
    var members:[MemberLight]? = nil
    
    var titleTranslations: Translations? = nil
    var descriptionTranslations: Translations? = nil
    
    var status = ""
    private var statusChangedAt:String? = nil
    private var createdAt:String? = nil
    private var updatedAt:String? = nil
    
    func getChangedStatusDate() -> Date? {
        return statusChangedAt == nil ? nil : Utils.getDateFromWSDateString(statusChangedAt)
    }
    
    func getCreateUpdateDate() -> (dateStr:String,isCreated:Bool) {
        var date:Date? = nil
        var isCreated = true
        
        let createdDate = Utils.getDateFromWSDateString(createdAt)
        let updateDate = Utils.getDateFromWSDateString(updatedAt)
        
        isCreated = createdDate == updateDate
        date = isCreated ?  createdDate : updateDate
        
        let dateStr = Utils.formatEventDateName(date: date)
        
        return (dateStr,isCreated)
    }
    
    private var recurrency:Int? = nil
    private var _recurrence:EventRecurrence = .once
    var recurrence:EventRecurrence {
        get {
            if let recurrency = recurrency {
                switch recurrency {
                case 7: return .week
                case 14: return .every2Weeks
                case 31: return .month
                default:
                    return .once
                }
            }
            else {
                return _recurrence
            }
        }
        set {
            _recurrence = newValue
        }
    }
    
    private var _startDate:Date? = nil
    var startDate:Date? {
        set {
            _startDate = newValue
            
            if let _value = newValue {
                metadata?.starts_at = "\(_value)"
            }
            else {
                metadata?.starts_at = nil
            }
        }
        get {
            return _startDate
        }
    }
    
    func getMetadateStartDate() -> Date? {
        return Utils.getDateFromWSDateString(metadata?.starts_at)
    }

    func getMetadateEndDate() -> Date? {
        return Utils.getDateFromWSDateString(metadata?.ends_at)
    }
    
    var startDateFormatted:String {
        get {
            return Utils.formatEventDate(date:Utils.getDateFromWSDateString(metadata?.starts_at))
        }
    }
    
    var startDateNameFormatted:String {
        get {
            return Utils.formatEventDateName(date:Utils.getDateFromWSDateString(metadata?.starts_at))
        }
    }
    
    var startDateTimeFormatted:String {
        get {
            return  Utils.formatEventDateTimeFull(date: Utils.getDateFromWSDateString(metadata?.starts_at))
        }
    }
    
    var startTimeFormatted:String {
        get {
            return  Utils.formatEventTime(date: Utils.getDateFromWSDateString(metadata?.starts_at))
        }
    }
    
    var startHourFormatted: String {
        get {
            return Utils.formatEventHour(date: Utils.getDateFromWSDateString(metadata?.starts_at))
        }
    }
    
    var endTimeFormatted:String {
        get {
            return  Utils.formatEventTime(date: Utils.getDateFromWSDateString(metadata?.ends_at))
        }
    }
    
    private var _endDate:Date? = nil
    var endDate:Date? {
        set {
            _endDate = newValue
            if let _value = newValue {
                metadata?.ends_at = "\(_value)"
            }
            else {
                metadata?.ends_at = nil
            }
        }
        get { return _endDate }
    }
    
    func getStartEndDate() -> (startDate:Date?,endDate:Date?) {
        return (Utils.getDateFromWSDateString(metadata?.starts_at),Utils.getDateFromWSDateString(metadata?.ends_at))
    }
    
    var endDateFormatted:String {
        get {
            return Utils.formatEventDate(date:Utils.getDateFromWSDateString(metadata?.ends_at))
        }
    }
    
    var addressName:String? {
        set { metadata?.display_address = newValue }
        get {
            return metadata?.display_address ?? ""
        }
    }
    
    var getCurrentImageUrl:String? {
        get {
            if metadata?.portrait_url != nil {
                return metadata?.portrait_url
            }
            return metadata?.landscape_url
        }
    }
    
    func isCanceled() -> Bool {
        return status == "closed"
    }
    
    enum CodingKeys: String, CodingKey {
        case uid = "id"
        case uuid
        case uuid_v2
        case title
        case descriptionEvent = "description"
        case shareUrl = "share_url"
        case imageUrl = "image_url"
        case isOnline = "online"
        case onlineEventUrl = "event_url"
        case distance
        case author
        case location
        case metadata
        
        case interests
        case neighborhoods
        case imageId = "entourage_image_id"
        
        case recurrency
        case membersCount = "members_count"
        case members
        case isMember = "member"
        case status
        case posts
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case statusChangedAt = "status_changed_at"
        case titleTranslations = "title_translations"
        case descriptionTranslations = "description_translations"
    }
    
    func dictionaryForWS() -> [String:Any] {
        var dict = [String:Any]()
        
        if title.count > 0 {
            dict["title"] = title
        }
        
        if !(descriptionEvent?.isEmpty ?? true) {
            dict["description"] = descriptionEvent!
        }
        
        if let imageId = imageId {
            dict["entourage_image_id"] = imageId
        }
        
        if location?.latitude ?? 0 != 0 {
            dict["latitude"] = location!.latitude
        }
        else {
            dict["latitude"] = 0
        }
        if distance ?? 0 != 0 {
            dict["distance"] = distance
        }else {
            dict["distance"] = 0
        }
        
        if location?.longitude ?? 0 != 0 {
            dict["longitude"] = location!.longitude
        }
        else {
            dict["longitude"] = 0
        }
        
        
        
        //Interests
        if let interests = interests, interests.count > 0 {
            dict["interests"] = interests
        }
        if let tagOtherMessage = tagOtherMessage {
            dict["other_interest"] = tagOtherMessage
        }
        
        
        if let event_url = onlineEventUrl {
            dict["event_url"] = event_url
        }
        
        if let isOnline = isOnline {
            dict["online"] = isOnline
        }
        else {
            dict["online"] = false
        }
        
        if let neighborhoods = neighborhoods, neighborhoods.count > 0 {
            var _ids = [Int]()
            for neighborhood in neighborhoods {
                _ids.append(neighborhood.id)
            }
            dict["neighborhood_ids"] = _ids
        }
        
        switch recurrence {
        case .once:
            break
        case .week:
            dict["recurrency"] = 7
        case .every2Weeks:
            dict["recurrency"] = 14
        case .month:
            dict["recurrency"] = 31
        }
        
        //MEtadatas
        var metadatas = [String:Any]()
        if addressName?.count ?? 0 > 0 {
            metadatas["place_name"] = addressName!
        }
        else {
            metadatas["place_name"] = ""
        }
        
        if metadata?.street_address.count ?? 0 > 0 {
            metadatas["street_address"] = metadata?.street_address
        }
        else {
            metadatas["street_address"] = ""
        }
       
        if metadata?.google_place_id?.count ?? 0 > 0 {
            metadatas["google_place_id"] = metadata!.google_place_id!
        }
        else {
            metadatas["google_place_id"] = ""
        }
        
        if metadata?.starts_at?.count ?? 0 > 0 {
            metadatas["starts_at"] = metadata!.starts_at!
        }
        else {
            metadatas["starts_at"] = ""
        }
        
        if metadata?.ends_at?.count ?? 0 > 0 {
            metadatas["ends_at"] = metadata!.ends_at!
        }
        else {
            metadatas["ends_at"] = ""
        }
        
        if let place = metadata?.place_limit , place > 0 {
            metadatas["place_limit"] = place
        }

        dict["metadata"] = metadatas
        
        return dict
    }
    
    //Use to sort events in months Dicts
    static func getArrayOfDateSorted(events:[Event], isAscendant:Bool) -> [Dictionary<MonthYearKey, [Event]>.Element] {
        let dict = Dictionary(grouping: events.filter { $0.getStartEndDate().startDate != nil }.sorted(by: {$0.getStartEndDate().startDate! < $1.getStartEndDate().startDate! })) { (event) -> MonthYearKey in
            guard let startDate = event.getStartEndDate().startDate else { return MonthYearKey(monthId: 0, dateString: "-") }
            
            let date = Calendar.current.dateComponents([.year, .month], from: startDate)
            guard let month = date.month, let year = date.year else { return MonthYearKey(monthId: 0, dateString: "-") }
            
            let df = DateFormatter()
            df.locale = Locale.getPreferredLocale()
            let monthLiterral = df.standaloneMonthSymbols[month - 1].localizedCapitalized
            
            let newCalendar = Calendar(identifier: .gregorian)
            let comp = DateComponents(year: year, month: month, day: 0, hour: 0, minute: 0, second: 0)
           
            let newDate = newCalendar.date(from: comp)!
            
            return MonthYearKey(monthId: month, date: newDate, dateString: "\(monthLiterral) \(year)")
        }
        
        if isAscendant {
            return dict.sorted { $0.key.date ?? Date() < $1.key.date ?? Date() }
        }
        
        return dict.sorted { $0.key.date ?? Date() > $1.key.date ?? Date() }
    }
}

struct EventLocation:Codable {
    var latitude:Double? = nil
    var longitude:Double? = nil
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
}

struct EventMetadata:Codable {
    var starts_at:String? = nil
    var ends_at:String? = nil
    var place_name:String = ""
    var street_address:String = ""
    var google_place_id:String? = nil
    var display_address:String? = nil
    var place_limit:Int? = 0
    var portrait_url:String? = nil
    var landscape_url:String? = nil
    
    var hasPlaceLimit:Bool? {
        get {
            if place_limit == nil {
                return nil
            }
            return place_limit ?? 0 > 0
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case starts_at
        case ends_at
        case place_name
        case street_address
        case google_place_id
        case display_address
        case place_limit
        case portrait_url
        case landscape_url
    }
}

struct EventAuthor: Codable {
    var uid: Int
    private var _displayName: String? = nil
    var avatarURL: String? = nil
    var partner: Partner? = nil
    var communityRoles: [String]? = nil
    
    var displayName: String {
        get {
            return _displayName ?? "-"
        }
        set(newName) {
            _displayName = newName
        }
    }
    
    private var createdAt: String? = nil
    var creationDate: Date? {
        get {
            return Utils.getDateFromWSDateString(createdAt)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case uid = "id"
        case _displayName = "display_name"
        case avatarURL = "avatar_url"
        case partner
        case createdAt = "created_at"
        case communityRoles = "community_roles"
    }
}


//MARK: - EventImage -
struct EventImage:Codable {
    var id:Int
    var title:String?
    var url_image_landscape:String? = ""
    var url_image_landscape_small:String? = ""
    var url_image_portrait:String? = ""
    var url_image_portrait_small:String? = ""
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case url_image_landscape = "landscape_url"
        case url_image_landscape_small = "landscape_small_url"
        case url_image_portrait = "portrait_url"
        case url_image_portrait_small = "portrait_small_url"
    }
}


enum EventRecurrence: Int {
    case once = 1
    case week = 2
    case every2Weeks = 3
    case month = 4
    
    func getDescription() -> String {
        switch self {
        case .once:
            return "recurrence_once".localized
        case .week:
            return "recurrence_week".localized
        case .every2Weeks:
            return "recurrence_every2Weeks".localized
        case .month:
            return "recurrence_month".localized
        }
    }
}

struct EventNeighborhood:Codable {
    var id:Int
    var name:String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}

//MARK: - Event for editing -
struct EventEditing {
    var uid:Int = 0
    var title:String? = nil
    var descriptionEvent:String? = nil
    var imageId:Int? = nil
    
    var isOnline:Bool? = nil
    var onlineEventUrl:String? = nil
    
    var location:EventLocation? = nil
    
    var metadata:EventMetadataEditing? = nil
    
    var interests:[String]? = nil
    var tagOtherMessage:String? = nil
    
    var neighborhoods:[EventNeighborhood]? = nil
    
    var recurrence:EventRecurrence? = nil
    
    private var _startDate:Date? = nil
    var startDate:Date? {
        set {
            _startDate = newValue
            
            if let _value = newValue {
                metadata?.starts_at = "\(_value)"
            }
            else {
                metadata?.starts_at = nil
            }
        }
        get {
            return _startDate
        }
    }
    
    private var _endDate:Date? = nil
    var endDate:Date? {
        set {
            _endDate = newValue
            if let _value = newValue {
                metadata?.ends_at = "\(_value)"
            }
            else {
                metadata?.ends_at = nil
            }
        }
        get { return _endDate }
    }
    
    func dictionaryForWS() -> [String:Any] {
        var dict = [String:Any]()
        
        if let title = title {
            dict["title"] = title
        }
        if let descriptionEvent = descriptionEvent {
            dict["description"] = descriptionEvent
        }
        if let imageId = imageId {
            dict["entourage_image_id"] = imageId
        }
        
        if location?.latitude ?? 0 != 0 {
            dict["latitude"] = location!.latitude
        }
        if location?.longitude ?? 0 != 0 {
            dict["longitude"] = location!.longitude
        }
        
        if let interests = interests {
            dict["interests"] = interests
        }
        
        if let neighborhoods = neighborhoods, neighborhoods.count > 0 {
            var _ids = [Int]()
            for neighborhood in neighborhoods {
                _ids.append(neighborhood.id)
            }
            dict["neighborhood_ids"] = _ids
        }
        else {
            dict["neighborhood_ids"] = [Int]()
        }

        if let tagOtherMessage = tagOtherMessage {
            dict["other_interest"] = tagOtherMessage
        }
        if let isOnline = isOnline {
            dict["online"] = isOnline
        }
        
        if let onlineEventUrl = onlineEventUrl {
            dict["event_url"] = onlineEventUrl
        }
        
        if let recurrence = recurrence {
            switch recurrence {
            case .once:
                dict["recurrency"] = 0
            case .week:
                dict["recurrency"] = 7
            case .every2Weeks:
                dict["recurrency"] = 14
            case .month:
                dict["recurrency"] = 31
            }
        }
        
        var metadatas = [String:Any]()
        if let newStartDate = metadata?.starts_at {
            metadatas["starts_at"] = newStartDate
        }
        
        if let newEndDate = metadata?.ends_at {
            metadatas["ends_at"] = newEndDate
        }

        if let place_name = metadata?.place_name {
            metadatas["place_name"] = place_name
        }
        
        if let newGoogle_place_id = metadata?.google_place_id {
            metadatas["google_place_id"] = newGoogle_place_id
        }
        
        if let place = metadata?.place_limit  {
            metadatas["place_limit"] = place
        }
       
        if metadatas.count > 0 {
            dict["metadata"] = metadatas
        }
        
        return dict
    }
}


struct EventMetadataEditing {
    var starts_at:String? = nil
    var ends_at:String? = nil
    var place_name:String? = nil
    var google_place_id:String? = nil
    var place_limit:Int? = 0
    var hasPlaceLimit:Bool? {
        get {
            if place_limit == nil {
                return nil
            }
            return place_limit ?? 0 > 0
        }
    }
}


extension Event {
    
    //Function to see if event is passed or not
    func checkIsEventPassed()-> Bool{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        guard let date = dateFormatter.date(from: self.endDateFormatted) else {
            print("Error: Invalid date")
            return false
        }
        // get tomorrow's date
        let tomorrow = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        if date < tomorrow {
            return true
        } else {
            return false
        }
    }
    
}

class TagsUtils {
    static func showTagTranslated(_ section: String) -> String {
        switch section.lowercased() {
        //EVENTS INTERESTS
        case "activites", "activités manuelles":
            return NSLocalizedString("interest_activites".localized, comment: "")
        case "animaux":
            return NSLocalizedString("interest_animaux".localized, comment: "")
        case "bien-etre", "bien-être":
            return NSLocalizedString("interest_bien_etre".localized, comment: "")
        case "cuisine":
            return NSLocalizedString("interest_cuisine".localized, comment: "")
        case "culture", "art & culture":
            return NSLocalizedString("interest_culture".localized, comment: "")
        case "jeux":
            return NSLocalizedString("interest_jeux".localized, comment: "")
        case "nature":
            return NSLocalizedString("interest_nature".localized, comment: "")
        case "sport":
            return NSLocalizedString("interest_sport".localized, comment: "")
        case "marauding", "rencontres nomades":
            return NSLocalizedString("interest_marauding".localized, comment: "")
        case "other", "autre":
            return NSLocalizedString("interest_other".localized, comment: "")
            //ACTION TAGS
        case "social":
            return NSLocalizedString("action_social_name".localized, comment: "")
        case "clothes":
            return NSLocalizedString("action_clothes_name".localized, comment: "")
        case "equipment":
            return NSLocalizedString("action_equipment_name".localized, comment: "")
        case "hygiene":
            return NSLocalizedString("action_hygiene_name".localized, comment: "")
        case "services":
            return NSLocalizedString("action_services_name".localized, comment: "")
        case "service":
            return NSLocalizedString("action_services_name".localized, comment: "")
        
        case "temps de partage":
            return NSLocalizedString("action_social_name".localized, comment: "")

        case "vêtement":
            return NSLocalizedString("action_services_name".localized, comment: "")

        case "équipement":
            return NSLocalizedString("action_equipment_name".localized, comment: "")

        case "produit d'hygiène":
            return NSLocalizedString("action_hygiene_name".localized, comment: "")

        default:
            return section
        }
    }
    static func showSubTagTranslated(_ section: String) -> String {
        switch section {
        case "social":
            return NSLocalizedString("action_social_subname".localized, comment: "")
        case "clothes":
            return NSLocalizedString("action_clothes_subname".localized, comment: "")
        case "equipment":
            return NSLocalizedString("action_equipment_subname".localized, comment: "")
        case "hygiene":
            return NSLocalizedString("action_hygiene_subname".localized, comment: "")
        case "services":
            return NSLocalizedString("action_services_subname".localized, comment: "")
            
        case "café, activité...":
            return NSLocalizedString("action_social_subname".localized, comment: "")
        case "lessive, impression de documents...":
            return NSLocalizedString("action_services_subname".localized, comment: "")
        case "chaussures, manteau...":
            return NSLocalizedString("action_clothes_subname".localized, comment: "")
        case "téléphone, duvet...":
            return NSLocalizedString("action_equipment_subname".localized, comment: "")
        case "savon, protection hygiénique...":
            return NSLocalizedString("action_hygiene_subname".localized, comment: "")
            
        default:
            return NSLocalizedString("interest_other".localized, comment: "")
        }
    }
}
