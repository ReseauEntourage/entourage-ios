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
    
    static let bigCornerRadius:CGFloat = 35
    static let topPopViewControllerSpacing:CGFloat = 30
    
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
    
    static func getDefaultBackgroundBarColor() -> UIColor {
        return UIColor.white
    }
    
    static func getDefaultTintBarColor() -> UIColor {
        return UIColor.appOrange
    }
    
    //MARK: - Fonts with default color from Zeplin style guide -
    static func getFontTitle(size:CGFloat = 24) -> MJTextFontColorStyle {
        return MJTextFontColorStyle(font: getFontQuickSandBold(size: size), color: UIColor.white)
    }
    static func getFontTitleMontserrat(size:CGFloat = 20) -> MJTextFontColorStyle {
        return MJTextFontColorStyle(font: getFontMontSerratBold(size: size), color: UIColor.black)
    }
    static func getFontSubtitle(size:CGFloat = 20) -> MJTextFontColorStyle {
        return MJTextFontColorStyle(font: getFontNunitoSemiBold(size: size), color: UIColor.black)
    }
    static func getFontSectionActif(size:CGFloat = 15, color:UIColor = .appOrange) -> MJTextFontColorStyle {
        return MJTextFontColorStyle(font: getFontNunitoBold(size: size), color: color)
    }
    static func getFontSectionInactif(size:CGFloat = 14) -> MJTextFontColorStyle {
        return MJTextFontColorStyle(font: getFontNunitoSemiBold(size: size), color: UIColor.appOrangeLight)
    }
    
    static func getFontPopTitle(size:CGFloat = 15) -> MJTextFontColorStyle {
        return MJTextFontColorStyle(font: getFontNunitoBold(size: size), color: UIColor.black)
    }
    static func getFontTextItalic(size:CGFloat = 15) -> MJTextFontColorStyle {
        return MJTextFontColorStyle(font: getFontNunitoRegularItalic(size: size), color: UIColor.black)
    }
    static func getFontTextRegular(size:CGFloat = 15,color:UIColor = .black) -> MJTextFontColorStyle {
        return MJTextFontColorStyle(font: getFontNunitoRegular(size: size), color: color)
    }
    
    static func getFontSportStyle(size:CGFloat = 14) -> MJTextFontColorStyle {
        return MJTextFontColorStyle(font: getFontNunitoBold(size: size), color: UIColor.appOrange)
    }
    static func getFontMontserrat14(size:CGFloat = 14) -> MJTextFontColorStyle {
        return MJTextFontColorStyle(font: getFontMontSerrat(size: size), color: UIColor.black)
    }
    static func getFontH2(size:CGFloat = 15) -> MJTextFontColorStyle {
        return MJTextFontColorStyle(font: getFontQuickSandBold(size: size), color: UIColor.black)
    }
    static func getFontH5(size:CGFloat = 13) -> MJTextFontColorStyle {
        return MJTextFontColorStyle(font: getFontNunitoRegular(size: size), color: UIColor.appOrange)
    }
    static func getFontH6(size:CGFloat = 13) -> MJTextFontColorStyle {
        return MJTextFontColorStyle(font: getFontNunitoLight(size: size), color: UIColor.appOrange)
    }
    static func getFontCategoryBubble(size:CGFloat = 13) -> MJTextFontColorStyle {
        return MJTextFontColorStyle(font: getFontNunitoSemiBold(size: size), color: UIColor.appOrangeLight_50)
    }
    
    static func getFontLegend(size:CGFloat = 13) -> MJTextFontColorStyle {
        return MJTextFontColorStyle(font: getFontNunitoLight(size: size), color: UIColor.black)
    }
    
    static func getFontChampDefault(size:CGFloat = 13, color:UIColor = .appGrisSombre40) -> MJTextFontColorStyle {
        return MJTextFontColorStyle(font: getFontNunitoRegular(size: size), color: color)
    }
    
    static func getFontBoutonBlanc(size:CGFloat = 15, color:UIColor = .white) -> MJTextFontColorStyle {
        return MJTextFontColorStyle(font: getFontNunitoBold(size: size), color: color)
    }
    
    static func getFontBoutonOrange(size:CGFloat = 15, color:UIColor = .appOrange) -> MJTextFontColorStyle {
        return MJTextFontColorStyle(font: getFontNunitoBold(size: size), color: color)
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

//MARK: - MJTextFontColor Style -
struct MJTextFontColorStyle {
    var font:UIFont
    var color:UIColor
}
