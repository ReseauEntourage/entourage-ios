//
//  ApplicationTheme.swift
//  entourage
//  Copyright © 2022 Entourage. All rights reserved.
//

import UIKit

struct ApplicationTheme {
    //TODO: utilisé sur la page GMSAutocomplete si besoin on change ?
    static var backgroundThemeColor: UIColor = UIColor.appOrange
    static var labelNavBarColor: UIColor = UIColor.appGreyishBrown
    
    
    static func iPhoneHasNotch() -> Bool {
        var topPadding:CGFloat?
        
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            topPadding = window?.safeAreaInsets.top
        }
        else {
            let window = UIApplication.shared.keyWindow
            topPadding = window?.safeAreaInsets.top
        }
        return topPadding ?? 0  > 20
    }
    
    //MARK: - Fonts with default color from Zeplin style guide -
    static func getFontTitle(size:CGFloat = 24) -> (font:UIFont,color:UIColor) {
        return (getFontQuickSandBold(size: size), UIColor.white)
    }
    static func getFontTitleMontserrat(size:CGFloat = 20) -> (font:UIFont,color:UIColor) {
        return (getFontMontSerratBold(size: size), UIColor.black)
    }
    static func getFontSubtitle(size:CGFloat = 20) -> (font:UIFont,color:UIColor) {
        return (getFontNunitoSemiBold(size: size), UIColor.black)
    }
    static func getFontSectionActif(size:CGFloat = 15) -> (font:UIFont,color:UIColor) {
        return (getFontNunitoBold(size: size), UIColor.appOrange)
    }
    static func getFontSectionInactif(size:CGFloat = 14) -> (font:UIFont,color:UIColor) {
        return (getFontNunitoSemiBold(size: size), UIColor.appOrangeLight)
    }
    
    static func getFontPopTitle(size:CGFloat = 15) -> (font:UIFont,color:UIColor) {
        return (getFontNunitoBold(size: size), UIColor.black)
    }
    static func getFontTextItalic(size:CGFloat = 15) -> (font:UIFont,color:UIColor) {
        return (getFontNunitoRegularItalic(size: size), UIColor.black)
    }
    static func getFontTextRegular(size:CGFloat = 15) -> (font:UIFont,color:UIColor) {
        return (getFontNunitoRegular(size: size), UIColor.black)
    }
    
    static func getFontSportStyle(size:CGFloat = 14) -> (font:UIFont,color:UIColor) {
        return (getFontNunitoBold(size: size), UIColor.appOrange)
    }
    static func getFontMontserrat14(size:CGFloat = 14) -> (font:UIFont,color:UIColor) {
        return (getFontMontSerrat(size: size), UIColor.black)
    }
    static func getFontH5(size:CGFloat = 13) -> (font:UIFont,color:UIColor) {
        return (getFontNunitoRegular(size: size), UIColor.appOrange)
    }
    static func getFontH6(size:CGFloat = 13) -> (font:UIFont,color:UIColor) {
        return (getFontNunitoLight(size: size), UIColor.appOrange)
    }
    static func getFontCategoryBubble(size:CGFloat = 13) -> (font:UIFont,color:UIColor) {
        return (getFontNunitoSemiBold(size: size), UIColor.appOrangeLight_50)
    }
    
    //MARK: - Custom Fonts only from Zeplin -
    static func getFontNunitoBold(size:CGFloat) -> UIFont {
        return UIFont(name:"NunitoSans-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static func getFontNunitoSemiBold(size:CGFloat) -> UIFont {
        return UIFont(name:"NunitoSans-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static func getFontNunitoRegular(size:CGFloat) -> UIFont {
        return UIFont(name:"NunitoSans-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static func getFontNunitoLight(size:CGFloat) -> UIFont {
        return UIFont(name:"NunitoSans-Light", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static func getFontNunitoRegularItalic(size:CGFloat) -> UIFont {
        return UIFont(name:"NunitoSans-Italic", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static func getFontMontSerrat(size:CGFloat) -> UIFont {
        return UIFont(name:"Montserrat-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static func getFontMontSerratBold(size:CGFloat) -> UIFont {
        return UIFont(name:"Montserrat-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static func getFontQuickSandBold(size:CGFloat) -> UIFont {
        return UIFont(name:"Quicksand-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
