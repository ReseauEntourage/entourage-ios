//
//  GlobalObjects.swift
//  entourage
//
//  Created by Jerome on 12/07/2022.
//

import Foundation


//MARK: - Messages Post + Comments -
struct PostMessage:Codable {
    var uid:Int = 0
    var content:String? = ""
    
    var createdDate: Date? {
        get {
            guard let date = Utils.getDateFromWSDateString(createdDateString) else {
                return nil
            }
            return date
        }
    }
    
    var createdDateFormatted:String {
        get {
            return Utils.formatEventDate(date:createdDate)
        }
    }
    
    var createdDateTimeFormatted:String {
        get {
            return Utils.formatEventDateTime(date:createdDate)
        }
    }
    
    var createdTimeFormatted:String {
        get {
            return Utils.formatEventTime(date:createdDate)
        }
    }
    
    var isPostImage:Bool {
        get {
            return messageImageUrl != nil
        }
    }
    
    var createdDateString:String = ""
    var parentPostId:Int? = nil
    var hasComments:Bool? = false
    var user:UserLightNeighborhood? = nil
    var commentsCount:Int? = 0
    var messageImageUrl:String? = nil
    var status:String? = nil
    
    var isRetryMsg = false
    
    private var read:Bool? = nil
    var isRead:Bool {
        get {
            return read ?? false
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case uid = "id"
        case content
        case user
        case createdDateString = "created_at"
        case parentPostId = "post_id"
        case hasComments = "has_comments"
        case commentsCount = "comments_count"
        case messageImageUrl = "image_url"
        case read
        case status
    }
    
    //Use to sort messages in days Dicts
    static func getArrayOfDateSorted(messages:[PostMessage], isAscendant:Bool) -> [Dictionary<DayMonthYearKey, [PostMessage]>.Element] {
        let dict = Dictionary(grouping: messages) { (message) -> DayMonthYearKey in
            let date = message.createdDate ?? Date() // utilise une date par défaut si createdDate est nulle
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            let day = components.day ?? 0
            let month = components.month ?? 0
            let year = components.year ?? 0

            let df = DateFormatter()
            df.locale = Locale.getPreferredLocale()
            let monthLiterral = df.standaloneMonthSymbols[month - 1]
            let dayLitteral:String = date.dayNameOfWeek()?.localizedCapitalized ?? "-"

            return DayMonthYearKey(dayId: day, monthId: month, date: date, dateString: "\(dayLitteral) \(day) \(monthLiterral) \(year)")
        }
        
        let sortedDict = isAscendant ? dict.sorted { $0.key.date ?? Date() < $1.key.date ?? Date() } : dict.sorted { $0.key.date ?? Date() > $1.key.date ?? Date() }
        
        return sortedDict
    }
}

struct DayMonthYearKey:Hashable {
    var dayId:Int = 0
    var monthId:Int = 0
    var date:Date? = nil
    var dateString:String = ""
}

//MARK: -MemberLight use on feed -> Event/neighborhood -
struct MemberLight:Codable {
    var uid:Int
    var username:String?
    var imageUrl:String?
    
    enum CodingKeys: String, CodingKey {
        case uid = "id"
        case username = "display_name"
        case imageUrl = "avatar_url"
    }
}
