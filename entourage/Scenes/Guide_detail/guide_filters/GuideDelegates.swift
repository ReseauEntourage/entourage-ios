//
//  OTGuideFile.swift
//  entourage
//
//  Created by Jr on 18/09/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import Foundation

//MARK: - Delegates Guide Filters -
protocol ChangeFilterGDSDelegate:NSObject {
    func changeAtPosition(_ position:Int,isActive:Bool)
    func changeTop(_ position:Int)
}

protocol GuideFilterDelegate: NSObject {
    func getSolidarityFilter() -> GuideFilters
    func solidarityFilterChanged(_ filter: GuideFilters!)
}

@objc protocol ClosePopDelegate {
    func close()
}
