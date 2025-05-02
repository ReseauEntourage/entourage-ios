//
//  Extensions_UIColor.swift
//  entourage
//
//  Created by Jerome on 21/01/2022.
//

import Foundation
import UIKit

//MARK: - Extensions UIColor -
extension UIColor {
    static var appBlack30: UIColor {
        return UIColor(red: 30 / 255.0, green: 30 / 255.0, blue: 30 / 255.0, alpha: 1.0)
    }
    static var appWhite246: UIColor {
        return UIColor(red: 246 / 255.0, green: 246 / 255.0, blue: 246 / 255.0, alpha: 1.0)
    }
    static var appGrey165: UIColor {
        return UIColor(red: 165 / 255.0, green: 165 / 255.0, blue: 156 / 255.0, alpha: 1.0)
    }
    static var appGrey151: UIColor {
        return UIColor(red: 151 / 255.0, green: 151 / 255.0, blue: 151 / 255.0, alpha: 1.0)
    }
    static var appGreyishBrown: UIColor {
        return UIColor(red: 74 / 255.0, green: 74 / 255.0, blue: 74 / 255.0, alpha: 1.0)
    }
    
    static var appPaleGrey: UIColor {
        return UIColor(red: 239 / 255.0, green: 239 / 255.0, blue: 244 / 255.0, alpha: 1.0)
    }
    
    //MARK: - POI colors -
    static var poiCategory1: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 197.0 / 255.0, blue: 127.0 / 255.0, alpha: 1.0)
    }
    static var poiCategory2: UIColor {
        return UIColor(red: 202.0 / 255.0, green: 167.0 / 255.0, blue: 234.0 / 255.0, alpha: 1.0)
    }
    static var poiCategory3: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0)
    }
    static var poiCategory4: UIColor {
        return UIColor(red: 58.0 / 255.0, green: 215.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }
    static var poiCategory5: UIColor {
        return UIColor(red: 191.0 / 255.0, green: 191.0 / 255.0, blue: 185.0 / 255.0, alpha: 1.0)
    }
    static var poiCategory6: UIColor {
        return UIColor(red: 136.0 / 255.0, green: 192.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }
    static var poiCategory7: UIColor {
        return UIColor(red: 151.0 / 255.0, green: 215.0 / 255.0, blue: 145.0 / 255.0, alpha: 1.0)
    }
    static var poiCategory8: UIColor {
        return UIColor(red: 249.0 / 255.0, green: 159.0 / 255.0, blue: 124.0 / 255.0, alpha: 1.0)
    }
    static var poiCategory0: UIColor {
        return UIColor.black
    }
    
    //MARK: - New App version colors -
    static var appBeigeClair: UIColor {
        return UIColor(named: "BeigeClair") ?? .red
    }
    static var appBeigeClair2: UIColor {
        return UIColor(named: "BeigeClair2") ?? .red
    }
    static var appBeige: UIColor {
        return UIColor(named: "Beige") ?? .red
    }
    static var appBeigeLighter: UIColor {
        return UIColor(named: "beige_lighter") ?? .red
    }
    static var appBleu: UIColor {
        return UIColor(named: "Bleu_2nd") ?? .red
    }
    static var appJaune: UIColor {
        return UIColor(named: "Jaune_2nd") ?? .red
    }
    static var appOrange: UIColor {
        return UIColor(named: "orange_app") ?? .red
    }
    static var appOrangeDark: UIColor {
        return UIColor(named: "orange_dark") ?? .red
    }
    
    static var appOrangeLight: UIColor {
        return UIColor(named: "orange_light") ?? .red
    }
    static var appOrangeLight_50: UIColor {
        return UIColor(named: "orange_light_a50") ?? .red
    }
    static var appOrangeLight_70: UIColor {
        return UIColor(named: "orange_light_a70") ?? .red
    }
    static var appGreenLogout: UIColor {
        return UIColor(named: "green_logout") ?? .red
    }
    
    static var appGrisSombre: UIColor {
        return UIColor(named: "gris_sombre") ?? .red
    }
    static var appGrisReaction: UIColor {
        return UIColor(named: "grey_reaction") ?? .red
    }
    static var appGrisSombre40: UIColor {
        return UIColor(named: "gris_sombre_40") ?? .red
    }
    static var appGris112: UIColor {
        return UIColor(named: "gris_112") ?? .red
    }
    static var appGreyCellDeleted: UIColor {
        return UIColor(named: "grey_cell_deleted") ?? .red
    }
    static var appGreyTextDeleted: UIColor {
        return UIColor(named: "grey_text_deleted") ?? .red
    }
    
    static var rougeErreur: UIColor {
        return UIColor(named: "rouge_erreur") ?? .red
    }
    static var orangeMedium: UIColor {
        return UIColor.init(named: "orange_medium") ?? .red
    }
    static var appGreyOff: UIColor {
        return UIColor(named: "grey_off") ?? .red
    }
    convenience init(hexString: String) {
        let scanner = Scanner(string: hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
            let r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(hexNumber & 0x0000FF) / 255.0

            self.init(red: r, green: g, blue: b, alpha: 1.0)
        } else {
            self.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
}
