//
//  QuestionSurveyVoteCell.swift
//  entourage
//
//  Created by Clement entourage on 28/03/2024.
//

import Foundation
import UIKit

class QuestionSurveyVoteCell:UITableViewCell{
    
    //OUTLET
    @IBOutlet weak var ui_question_label: UILabel!
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        
    }
    
    func configure(title:String){
        self.ui_question_label.text = title
    }
}
