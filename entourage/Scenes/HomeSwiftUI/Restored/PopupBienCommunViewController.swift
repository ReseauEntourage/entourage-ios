//
//  PopupBienCommunViewControllerr.swift
//  entourage
//
//  Created by Clement entourage on 03/09/2024.
//

import UIKit

// Déclaration du protocole pour le delegate
protocol PopupBienCommunViewControllerDelegate: AnyObject {
    func didVote()
}

class PopupBienCommunViewController: UIViewController {
   
    // OUTLET
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_btn_vote: UIButton!
    @IBOutlet weak var ui_btn_cross: UIButton!
    
    // VARIABLE
    weak var delegate: PopupBienCommunViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuration des textes localisables
        ui_label_title.text = NSLocalizedString("popup_biencommun_title", comment: "")
        ui_btn_vote.setTitle(NSLocalizedString("popup_biencommun_vote", comment: ""), for: .normal)
        
        // Configuration des actions pour les boutons
        ui_btn_cross.addTarget(self, action: #selector(didTapCrossButton), for: .touchUpInside)
        ui_btn_vote.addTarget(self, action: #selector(didTapVoteButton), for: .touchUpInside)
    }
    
    // Action pour le bouton "croix" qui dismiss le ViewController
    @objc private func didTapCrossButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Action pour le bouton "vote" qui appelle la méthode du delegate
    @objc private func didTapVoteButton() {
        self.dismiss(animated: true) {
            self.delegate?.didVote()
        }
    }
}
