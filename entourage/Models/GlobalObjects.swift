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
    
    var createdDate:Date {
        get {
            return Utils.getDateFromWSDateString(createdDateString)
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
        let dict = Dictionary(grouping: messages.sorted(by: {$0.createdDate < $1.createdDate})) { (message) -> DayMonthYearKey in
            
            let date = Calendar.current.dateComponents([.year, .month,.day], from: (message.createdDate))
            
            guard let month = date.month, let year = date.year, let day = date.day else { return DayMonthYearKey(dayId:0, monthId: 0, dateString: "-")}
            
           
            
            let newCalendar = Calendar(identifier: .gregorian)
            let comp = DateComponents(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
            
            let newDate = newCalendar.date(from: comp)!
            
            let df = DateFormatter()
            df.locale = Locale.getPreferredLocale()
            let monthLiterral = df.standaloneMonthSymbols[month - 1]
            let dayLitteral:String = message.createdDate.dayNameOfWeek()?.localizedCapitalized ?? "-"
            
            return DayMonthYearKey(dayId:day, monthId: month, date:newDate, dateString: "\(dayLitteral) \(day) \(monthLiterral) \(year)")
        }
        
        if isAscendant {
            return dict.sorted { $0.key.date ?? Date() < $1.key.date ?? Date() }
        }
        return dict.sorted { $0.key.date ?? Date() > $1.key.date ?? Date() }
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
