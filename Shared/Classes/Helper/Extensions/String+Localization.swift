//
//  String+Localization.swift
//  entourage
//
//  Created by Smart Care on 18/05/2018.
//  Copyright © 2018 Entourage. All rights reserved.
//

import Foundation

extension String {
    public static func localized (_ key:String) -> String {
        return OTLocalisationService.getLocalizedValue(forKey: key)
    }
}
