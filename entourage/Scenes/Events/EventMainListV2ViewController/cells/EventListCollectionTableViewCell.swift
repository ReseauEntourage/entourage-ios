//
//  EventListCollectionTableViewCell.swift
//  entourage
//
//  Created by Clement entourage on 19/09/2023.
//

import Foundation
import UIKit

protocol EventListCollectionTableViewCellDelegate {
    func paginateForMyEvent()
    func goToMyEvent(event:Event)
}

enum MyEventCollectionDTO{
    case myEvent(event:Event)
}

class EventListCollectionTableViewCell:UITableViewCell{
    
    //OUTLET
    @IBOutlet weak var ui_collection_view: UICollectionView!
    
    //VARIABLE
    var tableDTO = [MyEventCollectionDTO]()
    var delegate:EventListCollectionTableViewCellDelegate?
    private var nbOfItemsBeforePagingReload = 5
    class var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        setupCollectionView()
    }
    
    func configure(events:[Event]){
        tableDTO.removeAll()
        for event in events {
            tableDTO.append(.myEvent(event: event))
        }
        ui_collection_view.reloadData()
    }
    
    private func setupCollectionView() {
        ui_collection_view.delegate = self
        ui_collection_view.dataSource = self
        // Enregistrement de la cellule de collectionView
        ui_collection_view.register(UINib(nibName: MyEventCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MyEventCollectionViewCell.identifier)
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 150, height: 170)
        layout.scrollDirection = .horizontal
        ui_collection_view.setCollectionViewLayout(layout, animated: true)
        ui_collection_view.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0) // Vous pouvez changer "50" par l'espace désiré

    }
}

extension EventListCollectionTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Retourner le nombre d'articles désiré
        return tableDTO.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch tableDTO[indexPath.row]{
        case .myEvent(let event):
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyEventCollectionViewCell", for: indexPath) as? MyEventCollectionViewCell{
                cell.configure(event: event)
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastIndex = tableDTO.count - nbOfItemsBeforePagingReload
        if indexPath.row == lastIndex {
            self.delegate?.paginateForMyEvent()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 170)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch tableDTO[indexPath.row]{
            
        case .myEvent(let event):
            delegate?.goToMyEvent(event: event)
        }
    }
}
