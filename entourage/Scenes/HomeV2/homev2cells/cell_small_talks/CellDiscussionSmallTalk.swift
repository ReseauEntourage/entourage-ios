//
//  CellDiscussionSmallTalk.swift
//  entourage
//
//  Created by Clement entourage on 14/05/2025.
//

import Foundation
import UIKit

class CellDiscussionSmallTalk: UICollectionViewCell {

    // OUTLET
    @IBOutlet weak var ui_img_avatar_one: UIImageView!
    @IBOutlet weak var ui_img_avatar_2: UIImageView!
    @IBOutlet weak var ui_img_avatar_3: UIImageView!
    @IBOutlet weak var ui_img_avatar_4: UIImageView!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_subtitle: UILabel!
    @IBOutlet weak var ui_contraint_start_title: NSLayoutConstraint!
    @IBOutlet weak var ui_label_new_message: UILabel!
    @IBOutlet weak var round_new_message: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with request: UserSmallTalkRequest) {
        ui_label_title.text = "small_talk_title_conversation".localized
        var members = request.smalltalk?.members ?? []

        if let currentSid = UserDefaults.currentUser?.sid {
            if let index = members.firstIndex(where: { $0.id == currentSid }) {
                members.remove(at: index)
            }
        }

        ui_label_subtitle.text = members
            .map { $0.display_name }
            .joined(separator: ", ")
        ui_label_subtitle.setFontBody(size: 15)

        let avatars = members.compactMap { $0.avatar_url }

        // Assurez-vous que tous les UIImageView sont visibles
        ui_img_avatar_one.isHidden = false
        ui_img_avatar_2.isHidden = false
        ui_img_avatar_3.isHidden = false
        ui_img_avatar_4.isHidden = false

        // Utiliser un placeholder pour les avatars vides
        if members.indices.contains(0) {
            let avatarUrl = avatars.count > 0 ? avatars[0] : nil
            ui_img_avatar_one.sd_setImage(with: avatarUrl != nil ? URL(string: avatarUrl!) : nil, placeholderImage: UIImage(named: "placeholder_user"))
            ui_contraint_start_title.constant = 10
        }
        if members.indices.contains(1) {
            let avatarUrl = avatars.count > 1 ? avatars[1] : nil
            ui_img_avatar_2.sd_setImage(with: avatarUrl != nil ? URL(string: avatarUrl!) : nil, placeholderImage: UIImage(named: "placeholder_user"))
            ui_contraint_start_title.constant = 30
        }
        if members.indices.contains(2) {
            let avatarUrl = avatars.count > 2 ? avatars[2] : nil
            ui_img_avatar_3.sd_setImage(with: avatarUrl != nil ? URL(string: avatarUrl!) : nil, placeholderImage: UIImage(named: "placeholder_user"))
            ui_contraint_start_title.constant = 50
        }
        if members.indices.contains(3) {
            let avatarUrl = avatars.count > 3 ? avatars[3] : nil
            ui_img_avatar_4.sd_setImage(with: avatarUrl != nil ? URL(string: avatarUrl!) : nil, placeholderImage: UIImage(named: "placeholder_user"))
            ui_contraint_start_title.constant = 70
        }
        guard let number = request.number_of_unread_messages else{
            self.ui_label_new_message.isHidden = true
            return
        }
        self.ui_label_new_message.setFontBody(size: 13)
        if number > 0 {
            self.ui_label_new_message.isHidden = false
            self.round_new_message.isHidden = false
            self.ui_label_new_message.text = String(number) + "title_new_message".localized
        }else{
            self.ui_label_new_message.isHidden = true
            self.round_new_message.isHidden = true
        }
    }
}
