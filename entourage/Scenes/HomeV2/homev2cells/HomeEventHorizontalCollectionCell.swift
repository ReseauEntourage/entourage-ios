//
//  HomeEventHorizontalCollectionCell.swift
//  entourage
//
//  Created by Clement entourage on 04/10/2023.
//

import Foundation
import UIKit

protocol HomeEventHCCDelegate {
    func goToMyEvent(event:Event)

}


enum HomeEventCollectionDTO{
    case eventCell(event:Event)
}

class HomeEventHorizontalCollectionCell:UITableViewCell{
    
    //OUTLET
    @IBOutlet weak var ui_collection_view: UICollectionView!
    
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    var tableDTO = [HomeEventCollectionDTO]()
    var delegate:HomeEventHCCDelegate?
    
    override  func awakeFromNib() {
        self.contentView.backgroundColor = UIColor(named: "white_orange_home")
        ui_collection_view.delegate = self
        ui_collection_view.dataSource = self
        // Enregistrement de la cellule de collectionView
        ui_collection_view.register(UINib(nibName: HomeCellEvent.identifier, bundle: nil), forCellWithReuseIdentifier: HomeCellEvent.identifier)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        ui_collection_view.setCollectionViewLayout(layout, animated: true)
        ui_collection_view.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0) // Vous
    }
    
    func configure(events:[Event]){
        tableDTO.removeAll()
        for event in events {
            tableDTO.append(.eventCell(event: event))
        }
        ui_collection_view.reloadData()
    }
    
}

extension HomeEventHorizontalCollectionCell:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tableDTO.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch tableDTO[indexPath.row]{
            
        case .eventCell(let event):
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCellEvent", for: indexPath) as? HomeCellEvent{
                cell.configure(event: event)
                return cell
            }
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 215)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch tableDTO[indexPath.row]{
        case .eventCell(let event):
            AnalyticsLoggerManager.logEvent(name: Action_Home_Event_Detail)
            delegate?.goToMyEvent(event: event)
        }
    }
}
