//
//  Utilitaires.swift
//  entourage
//
//  Created by Jr on 10/04/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit


@objc class Utils : NSObject {
    
        
    static func displayDistance(distance:Double) -> String {
        var distString = ""
        if distance < 1 {
            let distance_in_meter = 100 * distance
            distString = String.init(format: "Atm".localized, distance_in_meter.rounded())
            return distString
        }else{
            return String.init(format: "AtKm".localized, distance.rounded())
        }
    }
    
    static func displayBaseStringDistance(distance:Double)-> String {
        var distString = ""
        if distance < 1 {
            let distance_in_meter = 100 * distance
            distString = String(format: "%.0f m", distance_in_meter.rounded())
            return distString
        }else{
            distString = String(format: "%.0f km", distance.rounded())
            return distString
        }
    }

    
    
    static func formatString(messageTxt: String, messageTxtHighlight:String,fontColorType:MJTextFontColorStyle, fontColorTypeHighlight:MJTextFontColorStyle) -> NSAttributedString {
        let attributesNormal: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : fontColorType.font, NSAttributedString.Key.foregroundColor : fontColorType.color]
        let attributeColored: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font:  fontColorTypeHighlight.font,NSAttributedString.Key.foregroundColor : fontColorTypeHighlight.color]
        
        let message = messageTxt as NSString
        let messageAttributed = NSMutableAttributedString(string: message as String , attributes: attributesNormal)
        messageAttributed.addAttributes(attributeColored, range: message.range(of: messageTxtHighlight))
        
        return messageAttributed
    }
    
    @objc static func formatString(stringMessage: String, coloredTxt:String,color: UIColor = UIColor.white,colorHighlight:UIColor = UIColor.appOrange,fontSize: CGFloat = 15, fontWeight:UIFont.Weight = .regular,fontColoredWeight:UIFont.Weight = .regular) -> NSAttributedString {
        let attributesNormal: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize, weight: fontWeight), NSAttributedString.Key.foregroundColor : color]
        let attributeColored: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: fontSize, weight: fontColoredWeight),NSAttributedString.Key.foregroundColor : colorHighlight]
        
        let message = stringMessage as NSString
        let messageAttributed = NSMutableAttributedString(string: stringMessage as String , attributes: attributesNormal)
        messageAttributed.addAttributes(attributeColored, range: message.range(of: coloredTxt))
        
        return messageAttributed
    }
    
    @objc static func formatStringItalic(stringMessage: String,italicTxt:String,color: UIColor, colorHighlight:UIColor, fontSize: CGFloat = 15, fontWeight:UIFont.Weight = .regular) -> NSAttributedString {
        
        let attributesNormal: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize, weight: fontWeight), NSAttributedString.Key.foregroundColor : color]
        
        let attributeItalic: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font:  UIFont.italicSystemFont(ofSize: fontSize),NSAttributedString.Key.foregroundColor : colorHighlight]
        
        let message = stringMessage as NSString
        let messageAttributed = NSMutableAttributedString(string: stringMessage as String , attributes: attributesNormal)
        messageAttributed.addAttributes(attributeItalic, range: message.range(of: italicTxt))
        
        return messageAttributed
    }
    
    @objc static func formatStringItalicOnly(stringMessage: String,color: UIColor, fontSize: CGFloat = 15) -> NSAttributedString {
        let attributeItalic: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font:  UIFont.italicSystemFont(ofSize: fontSize),NSAttributedString.Key.foregroundColor : color]
        let messageAttributed = NSMutableAttributedString(string: stringMessage as String , attributes: attributeItalic)
        
        return messageAttributed
    }
    
    @objc static func formatStringUnderline(textString: String, textUnderlineString:String? = nil,textColor: UIColor, underlinedColor:UIColor? = nil, fontSize: CGFloat = 15, fontWeight:UIFont.Weight = .regular, font:UIFont? = nil) -> NSAttributedString {
        
        let underlineTxt = textUnderlineString ?? textString
        
        let colorUnderlined:UIColor = underlinedColor ?? textColor
        
        let currentFont:UIFont = font ?? UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        
        let attributesNormal: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : currentFont, NSAttributedString.Key.foregroundColor : textColor]
        
        let attributeItalic: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font:  currentFont,NSAttributedString.Key.foregroundColor : colorUnderlined, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        
        let message = textString as NSString
        let messageAttributed = NSMutableAttributedString(string: textString , attributes: attributesNormal)
        messageAttributed.addAttributes(attributeItalic, range: message.range(of: underlineTxt))
        
        return messageAttributed
    }
    
    static func validatePhoneFormat(countryCode:String?, phone:String) -> String {
        var correctPhone = phone.trimmingCharacters(in: .whitespaces)
        
        if correctPhone.starts(with: "0") {
            //correctPhone.remove(at: .init(encodedOffset: 0))
            correctPhone.remove(at: .init(utf16Offset: 0, in: correctPhone))
            if let _code = countryCode {
                correctPhone = _code + correctPhone
            }
            else {
                correctPhone = "+33\(correctPhone)"
            }
        }
        else if !correctPhone.starts(with: "+") {
            if let _code = countryCode {
                correctPhone = _code + correctPhone
            }
        }
        
        if !correctPhone.starts(with: "+") {
            correctPhone = "+\(correctPhone)"
        }
        
        return correctPhone
    }
    
    static func formatDateAgo(date: Date) -> String {
        
        let now = Date()
        let duration = now.timeIntervalSince(date)
        let minutes = Int(duration / 60)
        let hours = minutes / 60
        let days = hours / 24
        let weeks = days/7
        let months = weeks/4

        switch true {
        case months > 0:
            return String(format:"duration_month".localized,months)
        case weeks > 0:
            return String(format:"duration_weeks".localized,weeks)
        case days > 0:
            return String(format:"duration_days".localized,days)
        case hours > 0:
            return String(format:"duration_hours".localized,hours)
        case minutes > 0:
            return String(format:"duration_minutes".localized,minutes)
        default:
            return "il y a quelques secondes"
        }
    }

    
    static func getDateFromWSDateString(_ dateStr:String?) -> Date? {
        guard let dateStr = dateStr else {
            return nil
        }

        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: dateStr)
    }
    
    static func formatEventDate(date:Date?) -> String {
        var dateString = ""
        if date != nil {
            let dateFormat = DateFormatter()
            dateFormat.locale = Locale.getPreferredLocale()
            dateFormat.dateFormat = "dd.MM.YYYY"
            dateString =  dateFormat.string(from: date!)
        }
        
        return dateString
    }
    
    static func formatEventDateTime(date:Date?) -> String {
        var dateString = ""
        if date != nil {
            let dateFormat = DateFormatter()
            dateFormat.locale = Locale.getPreferredLocale()
            dateFormat.dateFormat = "dd.MM.YYYY à HH'h'mm"
            dateString =  dateFormat.string(from: date!)
        }
        
        return dateString
    }
    
    static func formatEventDateTimeFull(date:Date?) -> String {
        var dateString = ""
        if date != nil {
            let dateFormat = DateFormatter()
            dateFormat.locale = Locale.getPreferredLocale()
            dateFormat.dateFormat = "dd MMMM YYYY à HH'h'mm"
            dateString =  dateFormat.string(from: date!)
        }
        
        return dateString
    }
    
    static func formatEventTime(date:Date?) -> String {
        var dateString = ""
        if date != nil {
            let dateFormat = DateFormatter()
            dateFormat.locale = Locale.getPreferredLocale()
            dateFormat.dateFormat = "HH'h'mm"
            dateString =  dateFormat.string(from: date!)
        }
        
        return dateString
    }
    
    static func formatEventDateName(date:Date?, withDayName:Bool = false) -> String {
        var dateString = ""
        if date != nil {
            let dateFormat = DateFormatter()
            dateFormat.locale = Locale.getPreferredLocale()
            if withDayName {
                let dfName = DateFormatter()
                dfName.locale = Locale.getPreferredLocale()
                dfName.dateFormat = "EEEE"
                dateFormat.dateFormat = "dd MMMM YYYY"
                dateString =  "\(dfName.string(from: date!).capitalized) \(dateFormat.string(from: date!))"
            }
            else {
                dateFormat.dateFormat = "dd MMMM YYYY"
                dateString =  dateFormat.string(from: date!)
            }
            
        }
        
        return dateString
    }
    
    static func formatActionDateName(date:Date?,capitalizeFirst:Bool) -> String {
        var dateString = "-"
        guard let date = date else {
            return dateString
        }

        if Calendar.current.isDateInToday(date) {
            return capitalizeFirst ? "Today".localized : "today".localized
        }
        else if Calendar.current.isDateInYesterday(date) {
            return capitalizeFirst ? "Yesterday".localized: "yesterday".localized
        }
        
        let dateFormat = DateFormatter()
        dateFormat.locale = Locale.getPreferredLocale()
        dateFormat.dateFormat = "dd MMMM YYYY"
        dateString =  dateFormat.string(from: date)
        
        //dateString = capitalizeFirst ? "\("The".localized) \(dateString)" : "\("the".localized) \(dateString)"
        
        return dateString
    }
    
    static func formatMessageListDateName(date:Date?) -> String {
        var dateString = "-"
        guard let date = date else {
            return dateString
        }
        
        if Calendar.current.isDateInYesterday(date) {
            return "Yesterday".localized
        }
        
        if Calendar.current.isDateInToday(date) {
            let dateFormat = DateFormatter()
            dateFormat.locale = Locale.getPreferredLocale()
            dateFormat.dateFormat = "HH'h'mm"
            dateString =  dateFormat.string(from: date)
            
            return dateString
        }
        
        let dateFormat = DateFormatter()
        dateFormat.locale = Locale.getPreferredLocale()
        dateFormat.dateFormat = "dd MMM"
        dateString =  dateFormat.string(from: date)
        
        return dateString
    }
}

class ImageLoaderSwift {
    
    private static let cache = NSCache<NSString, NSData>()
    
    class func getImage(from urlString: String?, completionHandler: @escaping(_ image: UIImage?) -> ()) {
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            guard let urlString = urlString else {
                DispatchQueue.main.async { completionHandler(nil) }
                return
            }
            
            guard let url = URL.init(string: urlString) else {
                DispatchQueue.main.async { completionHandler(nil) }
                return
            }
            
            if let data = self.cache.object(forKey: url.absoluteString as NSString) {
                DispatchQueue.main.async { completionHandler(UIImage(data: data as Data)) }
                return
            }
            
            guard let data = NSData(contentsOf: url) else {
                DispatchQueue.main.async { completionHandler(nil) }
                return
            }
            
            self.cache.setObject(data, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async { completionHandler(UIImage(data: data as Data)) }
        }
    }
}
