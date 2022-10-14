//
//  Extensions_UIDevice.swift
//  entourage
//
//  Created by Jerome on 22/03/2022.
//

import Foundation

extension UIDevice {
    var deviceTypeScreen: DeviceTypeScreen {
        if UIDevice().userInterfaceIdiom == .phone {
            let screenHeight = UIScreen.main.nativeBounds.height
            switch screenHeight {
            case 1136:
                return .small
            case 1334:
                return .medium
            case 1792,
                1920,
                2208:
                return .mediumPlus
            case 2436:
                return .large
            case _ where screenHeight > 2688:
                return .extraLarge
            default:
                return .unknown
            }
        }
        return .unknown
    }
    
    enum DeviceTypeScreen: Int {
        // Small        = iPhone 5S, 5C, SE 1er
        // Medium       = iPhone 6, 6S, 7, 8, SE 2nd, SE 3nd
        // Medium+      = iPhone 6+, 6S+, 7+, 8+, Xr
        // Large        = iPhone X, Xs
        // ExtraLarge   = Xs Max +++++++
        case small
        case medium
        case mediumPlus
        case large
        case extraLarge
        case unknown
    }
}
