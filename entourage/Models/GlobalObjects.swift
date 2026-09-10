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
    var contentHtml:String? = ""
    
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
    
    var createdDateLongFormatted:String {
        get {
            return Utils.formatEventDateLong(date:createdDate)
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
    var contentTranslations:Translations? = nil
    var contentTranslationsHtml:Translations? = nil
    var reactions: [Reaction]?
    var reactionId:Int? = 0
    var survey: Survey?
    var messageType:String? = ""
    var surveyResponse: [Bool]? = []
    var autoPostFrom: AutoPostFrom? // Champ pour l'auto-post
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
        case contentHtml = "content_html"
        case user
        case createdDateString = "created_at"
        case parentPostId = "post_id"
        case hasComments = "has_comments"
        case commentsCount = "comments_count"
        case messageImageUrl = "image_url"
        case read
        case status
        case reactions
        case contentTranslations = "content_translations"
        case contentTranslationsHtml = "content_translations_html"
        case reactionId = "reaction_id"
        case survey
        case surveyResponse = "survey_response"
        case autoPostFrom = "auto_post_from"
        case messageType = "message_type"

    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uid = try container.decode(Int.self, forKey: .uid)
        content = try container.decodeIfPresent(String.self, forKey: .content)
        contentHtml = try container.decodeIfPresent(String.self, forKey: .contentHtml)
        createdDateString = try container.decodeIfPresent(String.self, forKey: .createdDateString) ?? ""
        // `post_id` peut être un entier, une chaîne contenant un entier, une chaîne vide (post
        // de premier niveau) ou absent (anciens payloads socket) selon le contexte — on essaie
        // les formes possibles plutôt que de faire échouer tout le decode du message.
        if let intValue = try? container.decode(Int.self, forKey: .parentPostId) {
            parentPostId = intValue
        } else if let stringValue = try? container.decode(String.self, forKey: .parentPostId) {
            parentPostId = Int(stringValue)
        } else {
            parentPostId = nil
        }
        hasComments = try container.decodeIfPresent(Bool.self, forKey: .hasComments)
        user = try container.decodeIfPresent(UserLightNeighborhood.self, forKey: .user)
        commentsCount = try container.decodeIfPresent(Int.self, forKey: .commentsCount)
        messageImageUrl = try container.decodeIfPresent(String.self, forKey: .messageImageUrl)
        read = try container.decodeIfPresent(Bool.self, forKey: .read)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        reactions = try container.decodeIfPresent([Reaction].self, forKey: .reactions)
        contentTranslations = try container.decodeIfPresent(Translations.self, forKey: .contentTranslations)
        contentTranslationsHtml = try container.decodeIfPresent(Translations.self, forKey: .contentTranslationsHtml)
        // L'API renvoie parfois `false` au lieu de `null`/un entier pour reaction_id
        // (constaté sur la réponse de création d'un message côté preprod) : on ignore
        // la valeur plutôt que de faire échouer tout le decode du message.
        reactionId = try? container.decodeIfPresent(Int.self, forKey: .reactionId)
        survey = try container.decodeIfPresent(Survey.self, forKey: .survey)
        surveyResponse = try container.decodeIfPresent([Bool].self, forKey: .surveyResponse)
        autoPostFrom = try container.decodeIfPresent(AutoPostFrom.self, forKey: .autoPostFrom)
        messageType = try container.decodeIfPresent(String.self, forKey: .messageType)
        isRetryMsg = false
    }

    /// Fusionne un message reçu par websocket avec la version locale déjà affichée : certains
    /// événements (`chat_message_updated`) peuvent renvoyer une projection plus légère que la
    /// réponse REST complète — on ne veut pas effacer des champs déjà connus (auteur, réactions)
    /// qu'une édition/suppression ne touche pourtant jamais.
    func mergingOverLocal(_ local: PostMessage) -> PostMessage {
        var merged = self
        if merged.user == nil { merged.user = local.user }
        if merged.reactions == nil { merged.reactions = local.reactions }
        if merged.reactionId == nil { merged.reactionId = local.reactionId }
        return merged
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

            var dateTitle = ""

            if Calendar.current.isDateInToday(date) {
                dateTitle = "Today".localized
            }
            else if Calendar.current.isDateInTomorrow(date) {
                dateTitle = "Tomorrow".localized
            }
            else {
                let df = DateFormatter()
                df.locale = Locale.getPreferredLocale()
                let monthLiterral = df.standaloneMonthSymbols[month - 1]
                let dayLitteral:String = date.dayNameOfWeek()?.localizedCapitalized ?? "-"
                dateTitle = "\(dayLitteral) \(day) \(monthLiterral) \(year)"
            }

            return DayMonthYearKey(dayId: day, monthId: month, yearId: year, date: date, dateString: dateTitle)
        }
        
        let sortedDict = isAscendant ? dict.sorted { $0.key.date ?? Date() < $1.key.date ?? Date() } : dict.sorted { $0.key.date ?? Date() > $1.key.date ?? Date() }
        
        return sortedDict
    }
}

struct DayMonthYearKey: Hashable {
    var dayId: Int = 0
    var monthId: Int = 0
    var yearId: Int = 0
    var date: Date? = nil
    var dateString: String = ""

    // Égalité/hash basés uniquement sur le jour calendaire (jour+mois+année) : `date` est un
    // horodatage précis à la seconde, propre à CHAQUE message — l'inclure dans l'égalité
    // empêchait tout regroupement (chaque message devenait son propre groupe de date).
    static func == (lhs: DayMonthYearKey, rhs: DayMonthYearKey) -> Bool {
        lhs.dayId == rhs.dayId && lhs.monthId == rhs.monthId && lhs.yearId == rhs.yearId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(dayId)
        hasher.combine(monthId)
        hasher.combine(yearId)
    }
}

struct MemberLight: Codable {
    var uid: Int
    var username: String?
    var imageUrl: String?
    var confirmedAt: String?
    var participateAt: String?
    var photoAcceptance: Bool?
    var roles: [String]?
    var partner: Partner?

    enum CodingKeys: String, CodingKey {
        case uid = "id"
        case username = "display_name"
        case imageUrl = "avatar_url"
        case confirmedAt = "confirmed_at"
        case participateAt = "participate_at"
        case photoAcceptance = "photo_acceptance"

        case roles
        case partner
    }
}


// Structure équivalente de Survey pour iOS
struct Survey: Codable {
    var choices: [String]
    var multiple: Bool
    var summary: [Int]

    enum CodingKeys: String, CodingKey {
        case choices
        case multiple
        case summary
    }
}
extension Survey {
    var totalVotes: Int {
        return summary.reduce(0, +)
    }
}

// MARK: - AutoPostFrom Struct
struct AutoPostFrom: Codable {
    var instanceType: String
    var instanceId: Int
    
    enum CodingKeys: String, CodingKey {
        case instanceType = "instance_type"
        case instanceId = "instance_id"
    }
}
