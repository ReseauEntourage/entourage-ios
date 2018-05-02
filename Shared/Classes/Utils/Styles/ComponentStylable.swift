//
//  ComponentStylable.swift
//  entourage
//
//  Created by Veronica on 02/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import Foundation

protocol ComponentStylable  {
    var font: UIFont { get }
    var textColor: UIColor { get }
    var backgroundColor: UIColor { get }
    var borderColor: UIColor { get }
    var isUnderlined: Bool { get }
}
