//
//  EnhancedOnboardingCollectionCell.swift
//  entourage
//
//  Created by Clement entourage on 23/05/2024.
//

import Foundation
import UIKit

class EnhancedOnboardingCollectionCell:UITableViewCell{
    
    //Outlet
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    //Variable
    var items: [String] = []

    override func awakeFromNib() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCollectionViewHeight()
    }

    func updateCollectionViewHeight() {
        collectionView.layoutIfNeeded()
        collectionViewHeightConstraint.constant = collectionView.contentSize.height
    }
    
    func setItems(_ items: [String]) {
        self.items = items
        collectionView.reloadData()
        updateCollectionViewHeight()
    }
    
}

extension EnhancedOnboardingCollectionCell:UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    
}
