//
//  HomeGroupHorizontalCollectionCell.swift
//  entourage
//
//  Created by Clement entourage on 04/10/2023.
//

import Foundation
import UIKit

protocol HomeGroupCCDelegate {
    func goToMyGroup(group:Neighborhood)

}

enum HomeGroupCollectionDTO {
    case groupCell(group:Neighborhood)
}

class HomeGroupHorizontalCollectionCell:UITableViewCell{
    
    //OUTLET
    @IBOutlet weak var ui_collection_view: UICollectionView!
    
    //VARIABLE
    var tableDTO = [HomeGroupCollectionDTO]()
    var delegate:HomeGroupCCDelegate?
    class var identifier: String {
        return String(describing: self)
    }
    
    override  func awakeFromNib() {
        self.contentView.backgroundColor = UIColor(named: "white_orange_home")
        ui_collection_view.delegate = self
        ui_collection_view.dataSource = self
        // Enregistrement de la cellule de collectionView
        ui_collection_view.register(UINib(nibName: HomeGroupCell.identifier, bundle: nil), forCellWithReuseIdentifier: HomeGroupCell.identifier)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        ui_collection_view.setCollectionViewLayout(layout, animated: true)
        ui_collection_view.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0) // Vous
    }
    
    func configure(groups:[Neighborhood]){
        tableDTO.removeAll()
        for group in groups {
            tableDTO.append(.groupCell(group: group))
        }
        ui_collection_view.reloadData()
    }
}

extension HomeGroupHorizontalCollectionCell:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tableDTO.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch tableDTO[indexPath.row]{
            
        case .groupCell(let group):
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeGroupCell", for: indexPath) as? HomeGroupCell{
                cell.configure(group: group)
                return cell
            }
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch tableDTO[indexPath.row]{
        case .groupCell(let group):
            delegate?.goToMyGroup(group: group)
        }
    }
}
