//
//  WelcomeTwoGroupExampleCell.swift
//  entourage
//
//  Created by Clement entourage on 30/05/2023.
//

import Foundation
import ActiveLabel
import UIKit

class WelcomeTwoGroupExampleCell:UITableViewCell{
    
    @IBOutlet weak var tvUserCell: UILabel!
    @IBOutlet weak var tvTag: UILabel!
    @IBOutlet weak var tvDate: UILabel!
    @IBOutlet weak var tv_desc_cell: ActiveLabel!

    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        tvTag.setVisibilityGone()
        tvUserCell.text = "Eric D."
        tvDate.text = "12.01.22"
        tv_desc_cell.text = "Bonjour les voisins parisiens. Je m'appelle Eric, et j'ai hâte de vous rencontrer autour des évènements du réseau entourage."
    }
    
}
