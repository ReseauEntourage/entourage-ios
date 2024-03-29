//
//  SectionOptionNameCell.swift
//  entourage
//
//  Created by Clement entourage on 25/03/2024.
//

import Foundation
import UIKit

class SectionOptionNameCell:UITableViewCell{
    
    //OUTLET
    @IBOutlet weak var ui_label_title_option: UILabel!
    @IBOutlet weak var ui_label_number_vote: UILabel!
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    
    override func awakeFromNib() {
        
    }
    
    func configure(title:String, countVote:Int){
        self.ui_label_title_option.text = title
        let voteKey = (countVote <= 1) ? "vote_singular" : "vote_plural"
        let localizedVoteText = NSLocalizedString(voteKey, comment: "")
        self.ui_label_number_vote.text = "\(countVote) \(localizedVoteText)"
    }
    
}
