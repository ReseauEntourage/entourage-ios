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
        ui_label_title.text = "small_talk_subtitle_match".localized
        ui_label_title.setFontBody(size: 15)
        configureOrangeButton(ui_btn, withTitle: "home_button_start".localized)
        ui_btn.addTarget(self, action: #selector(onBtnClick), for: .touchUpInside)
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
