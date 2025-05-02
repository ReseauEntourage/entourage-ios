//
//  HomeInitialPedagogicHorizontalCell.swift
//  entourage
//
//  Created by Clement entourage on 18/06/2024.
//

import Foundation
import UIKit

protocol HomeInitialPedagoCCDelegate {
    func goToPedago(pedago:PedagogicResource)

}

enum HomePedagoInitialDTO{
    case pedago(pedago:PedagogicResource)
}
class HomeInitialPedagogicHorizontalCell:UITableViewCell {
    
    //Outlet
    @IBOutlet weak var ui_collection_view: UICollectionView!
    
    //Variable
    var tableDTO = [HomePedagoInitialDTO]()
    var pedagos = [PedagogicResource]()
    var delegate:HomeInitialPedagoCCDelegate?
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        self.contentView.backgroundColor = UIColor(named: "white_orange_home")
        ui_collection_view.delegate = self
        ui_collection_view.dataSource = self
        // Enregistrement de la cellule de collectionView
        ui_collection_view.register(UINib(nibName: HomeInitialPedagoCell.identifier, bundle: nil), forCellWithReuseIdentifier: HomeInitialPedagoCell.identifier)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        ui_collection_view.setCollectionViewLayout(layout, animated: true)
        ui_collection_view.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0) // Vous
    }
    
    func configure(pedagos:[PedagogicResource]){
        tableDTO.removeAll()
        for pedago in pedagos {
            tableDTO.append(.pedago(pedago: pedago))
        }
        ui_collection_view.reloadData()
    }
    
}

extension HomeInitialPedagogicHorizontalCell:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tableDTO.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch tableDTO[indexPath.row]{
            
        case .pedago(let pedago ):
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeInitialPedagoCell", for: indexPath) as? HomeInitialPedagoCell{
                cell.configure(pedago: pedago)
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 115)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch tableDTO[indexPath.row]{
        case .pedago(let pedago):
            delegate?.goToPedago(pedago: pedago)
        }
    }
}
