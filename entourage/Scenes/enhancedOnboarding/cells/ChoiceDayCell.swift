//
//  ChoiceDayCell.swift
//  entourage
//
//  Created by Clement entourage on 13/11/2024.
//

import Foundation
import UIKit

class ChoiceDayCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    // OUTLET
    @IBOutlet weak var ui_title_day: UILabel!
    @IBOutlet weak var ui_collectionview_days: UICollectionView!
    @IBOutlet weak var ui_title_hours: UILabel!
    @IBOutlet weak var ui_collectionview_hours: UICollectionView!
    
    // VARIABLES
    class var identifier: String {
        return String(describing: self)
    }
    
    var days: [String] = []
    var hours: [String] = []
    var selectedDays: Set<Int> = []
    var selectedHours: Set<Int> = []

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialisation des collectionViews
        ui_collectionview_days.delegate = self
        ui_collectionview_days.dataSource = self
        ui_collectionview_days.allowsMultipleSelection = true
        
        ui_collectionview_hours.delegate = self
        ui_collectionview_hours.dataSource = self
        ui_collectionview_hours.allowsMultipleSelection = true
        
        // Enregistrement de la cellule pour la collectionView avec le XIB
        let nib = UINib(nibName: "SelectableDayAndHourCollectionViewCell", bundle: nil)
        ui_collectionview_days.register(nib, forCellWithReuseIdentifier: "SelectableDayAndHourCollectionViewCell")
        ui_collectionview_hours.register(nib, forCellWithReuseIdentifier: "SelectableDayAndHourCollectionViewCell")
    }
    
    func configure(days: [String], hours: [String]) {
        self.days = days
        self.hours = hours
        ui_collectionview_days.reloadData()
        ui_collectionview_hours.reloadData()
    }
    
    // MARK: - UICollectionView DataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == ui_collectionview_days ? days.count : hours.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectableDayAndHourCollectionViewCell", for: indexPath) as! SelectableDayAndHourCollectionViewCell
        let itemText = collectionView == ui_collectionview_days ? days[indexPath.item] : hours[indexPath.item]
        let isSelected = collectionView == ui_collectionview_days ? selectedDays.contains(indexPath.item) : selectedHours.contains(indexPath.item)
        
        cell.configure(with: itemText, isSelected: isSelected)
        
        return cell
    }
    
    // MARK: - UICollectionView Delegate Methods
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == ui_collectionview_days {
            selectedDays.insert(indexPath.item)
        } else {
            selectedHours.insert(indexPath.item)
        }
        collectionView.reloadItems(at: [indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == ui_collectionview_days {
            selectedDays.remove(indexPath.item)
        } else {
            selectedHours.remove(indexPath.item)
        }
        collectionView.reloadItems(at: [indexPath])
    }
}
