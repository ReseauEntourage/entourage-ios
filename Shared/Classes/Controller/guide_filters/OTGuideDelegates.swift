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
    func changeTop(_ position:Int,isActive:Bool)
    func updateTable()
}

protocol OTGuideFilterDelegate: NSObject {
    func getSolidarityFilter() -> OTGuideFilters
    func solidarityFilterChanged(_ filter: OTGuideFilters!)
}

