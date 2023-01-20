//
//  MenuInfo.swift
//  entourage
//
//  Created by Jerome on 16/03/2022.
//

import Foundation

struct MenuItemInfos {
    var title:String
    var url:String?
    var slug:String?
    var email:String?
    var openInApp = true
    
    init(title:String, url:String? = nil, slug:String? = nil,email:String? = nil, openInApp:Bool = true) {
        self.title = title
        self.url = url
        self.slug = slug
        self.email = email
        self.openInApp = openInApp
    }
}
