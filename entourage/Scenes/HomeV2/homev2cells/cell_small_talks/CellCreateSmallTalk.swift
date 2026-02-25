//
//  CellCreateSmallTalk.swift
//  entourage
//
//  Created by Clement entourage on 14/05/2025.
//

import Foundation
import UIKit

class CellCreateSmallTalk:UICollectionViewCell{
    
    //OUTLET
    @IBOutlet weak var ui_iv: UIImageView!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_btn: UIButton!
    
    //VARIABLE
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        ui_btn.addTarget(self, action: #selector(onBtnClick), for: .touchUpInside)
    }
    
    func setupUI() {
        let titleText = "home_v2_small_talk_card_title".localized
        let subtitleText = "home_v2_small_talk_card_subtitle".localized

        let attributedString = NSMutableAttributedString(string: titleText + "\n", attributes: [
            .font: ApplicationTheme.getFontQuickSandBold(size: 15),
            .foregroundColor: UIColor.black
        ])

        attributedString.append(NSAttributedString(string: subtitleText, attributes: [
            .font: ApplicationTheme.getFontNunitoRegular(size: 13),
            .foregroundColor: UIColor.black
        ]))

        ui_label_title.attributedText = attributedString
        ui_label_title.numberOfLines = 0

        configureOrangeButton(ui_btn, withTitle: "home_v2_small_talk_card_button".localized)
    }

    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 15)
        button.clipsToBounds = true
    }
    
    @objc func onBtnClick(){
        guard let collectionView = self.parentCollectionView(),
              let indexPath = self.indexPathInCollectionView(),
              let delegate = collectionView.delegate else {
            return
        }

        delegate.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
    
}
