//
//  Utilitaires.swift
//  entourage
//
//  Created by Jr on 10/04/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import Foundation


class Utilitaires {
    static func formatString(stringMessage: String, coloredTxt:String,color: UIColor = UIColor.white,colorHighlight:UIColor = UIColor.appOrange(),fontSize: CGFloat = 15, fontWeight:UIFont.Weight = .regular,fontColoredWeight:UIFont.Weight = .regular) -> NSAttributedString {
        let attributesNormal: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize, weight: fontWeight), NSAttributedString.Key.foregroundColor : color]
        let attributeColored: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: fontSize, weight: fontColoredWeight),NSAttributedString.Key.foregroundColor : colorHighlight]
        
        let message = stringMessage as NSString
        let messageAttributed = NSMutableAttributedString(string: stringMessage as String , attributes: attributesNormal)
        messageAttributed.addAttributes(attributeColored, range: message.range(of: coloredTxt))
        
        return messageAttributed
    }
}
