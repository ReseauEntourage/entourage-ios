//
//  CellDiscussionSmallTalk.swift
//  entourage
//
//  Created by Clement entourage on 14/05/2025.
//

import Foundation
import UIKit

class CellDiscussionSmallTalk:UICollectionViewCell {
    
    //OUTLET
    @IBOutlet weak var ui_img_avatar_one: UIImageView!
    @IBOutlet weak var ui_img_avatar_2: UIImageView!
    @IBOutlet weak var ui_img_avatar_3: UIImageView!
    @IBOutlet weak var ui_img_avatar_4: UIImageView!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_subtitle: UILabel!
    @IBOutlet weak var ui_contraint_start_title: NSLayoutConstraint!
    
    //VARIABLE
    
    override func awakeFromNib() {
    
    }
    
    func configure(with request: UserSmallTalkRequest) {
        ui_label_title.text = "small_talk_title_conversation".localized
        ui_label_subtitle.text = request.smalltalk?.members
            .map { $0.display_name }
            .joined(separator: ", ")
        ui_label_subtitle.setFontBody(size: 15)
        let avatars = request.smalltalk?.members.compactMap { $0.avatar_url }.filter { !$0.isEmpty } ?? []

        ui_img_avatar_one.isHidden = true
        ui_img_avatar_2.isHidden = true
        ui_img_avatar_3.isHidden = true
        ui_img_avatar_4.isHidden = true

        if avatars.indices.contains(0) {
            ui_img_avatar_one.isHidden = false
            ui_img_avatar_one.sd_setImage(with: URL(string: avatars[0]), placeholderImage: UIImage(named: "placeholder_avatar"))
            ui_contraint_start_title.constant = 10
        }
        if avatars.indices.contains(1) {
            ui_img_avatar_2.isHidden = false
            ui_img_avatar_2.sd_setImage(with: URL(string: avatars[1]), placeholderImage: UIImage(named: "placeholder_avatar"))
            ui_contraint_start_title.constant = 30
        }
        if avatars.indices.contains(2) {
            ui_img_avatar_3.isHidden = false
            ui_img_avatar_3.sd_setImage(with: URL(string: avatars[2]), placeholderImage: UIImage(named: "placeholder_avatar"))
            ui_contraint_start_title.constant = 50
        }
        if avatars.indices.contains(3) {
            ui_img_avatar_4.isHidden = false
            ui_img_avatar_4.sd_setImage(with: URL(string: avatars[3]), placeholderImage: UIImage(named: "placeholder_avatar"))
            ui_contraint_start_title.constant = 70
        }
    }
}
