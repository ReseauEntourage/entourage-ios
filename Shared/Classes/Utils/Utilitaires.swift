//
//  Utilitaires.swift
//  entourage
//
//  Created by Jr on 10/04/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import Foundation


@objc class Utilitaires : NSObject {
    @objc static func formatString(stringMessage: String, coloredTxt:String,color: UIColor = UIColor.white,colorHighlight:UIColor = UIColor.appOrange(),fontSize: CGFloat = 15, fontWeight:UIFont.Weight = .regular,fontColoredWeight:UIFont.Weight = .regular) -> NSAttributedString {
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
    
   @objc static func formatStringUnderline(stringMessage: String,underlineTxt:String,color: UIColor, colorHighlight:UIColor, fontSize: CGFloat = 15, fontWeight:UIFont.Weight = .regular) -> NSAttributedString {
        
        let attributesNormal: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize, weight: fontWeight), NSAttributedString.Key.foregroundColor : color]
        
        let attributeItalic: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: fontSize, weight: fontWeight),NSAttributedString.Key.foregroundColor : colorHighlight, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        
        let message = stringMessage as NSString
        let messageAttributed = NSMutableAttributedString(string: stringMessage as String , attributes: attributesNormal)
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
