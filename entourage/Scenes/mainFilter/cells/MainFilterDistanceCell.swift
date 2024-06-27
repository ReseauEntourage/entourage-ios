//
//  MainFilterDistanceCell.swift
//  entourage
//
//  Created by Clement entourage on 20/06/2024.
//

import Foundation
import UIKit

protocol MainFilterDistanceCellDelegate {
    func onRadiusChanged(radius:Float)
}
class MainFilterDistanceCell:UITableViewCell {
    
    //Outlet
    @IBOutlet weak var ui_slider_distance: UISlider!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_distance: UILabel!
    
    //Variable
    var delegate:MainFilterDistanceCellDelegate?
   
    override func awakeFromNib() {
        
    }
    
    func configure(distance:Int){
        ui_label_title.text = "main_filter_radius_cell_title".localized
        
        ui_slider_distance.minimumValue = 0
        ui_slider_distance.maximumValue = 100 // Ajuste selon tes besoins
        ui_slider_distance.value = Float(distance) // Valeur initiale
        
        ui_slider_distance.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        updateDistanceLabel()
    }
    @objc func sliderValueChanged(_ sender: UISlider) {
        updateDistanceLabel()
    }
    
    func updateDistanceLabel() {
        delegate?.onRadiusChanged(radius: ui_slider_distance.value)
        let distance = Int(ui_slider_distance.value)
        ui_label_distance.text = "\(distance) km"
    }
    
}
