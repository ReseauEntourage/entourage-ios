//
//  UIDevice.swift
//  entourage
//
//  Created by Work on 18/12/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import Foundation

@objc enum DeviceSize: Int {
    // Small        = iPhone 5, 5S, 5C, SE
    // Medium       = iPhone 6, 6S, 7, 8
    // Medium+      = iPhone 6+, 6S+, 7+, 8+, Xr
    // Large        = iPhone X, Xs
    // ExtraLarge   = Xs Max
    case small
    case medium
    case mediumPlus
    case large
    case extraLarge
    case unknownSize
}

@objc extension UIDevice {
    
    var deviceSize: DeviceSize {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
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
            case 2688:
                return .extraLarge
            default:
                return .unknownSize
            }
        }
        return .unknownSize
    }
}
