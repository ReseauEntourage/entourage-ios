//
//  MainFilterTitleCell.swift
//  entourage
//
//  Created by Clement entourage on 20/06/2024.
//

import Foundation
import UIKit

protocol MainFilterTitleCellDelegate {
    func onBackClick()
}

class MainFilterTitleCell: UITableViewCell {
    
    // Outlet
    @IBOutlet weak var ui_title_label: UILabel!
    @IBOutlet weak var ib_btn_back: UIImageView!
    
    // Variable
    var delegate: MainFilterTitleCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Ajouter le gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backButtonTapped))
        ib_btn_back.isUserInteractionEnabled = true
        ib_btn_back.addGestureRecognizer(tapGesture)
    }
    
    func configure(title: String) {
        self.ui_title_label.text = title
    }
    
    @objc func backButtonTapped() {
        delegate?.onBackClick()
    }
}
