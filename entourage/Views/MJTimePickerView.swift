//
//  MJTimePickerView.swift
//  entourage
//
//  Created by Jerome on 24/06/2022.
//

import UIKit

class MJTimePickerView: UIPickerView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config(localeStr: "fr-FR")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    func config(localeStr:String) {
        
        delegate = self
        dataSource = self
        
        backgroundColor = .white
    }
    
    func getTimeSelected() -> String {
        let hour = selectedRow(inComponent: 0)
        let hourStr = hour < 10 ? "0\(hour)" : "\(hour)"
        
        let minutes = selectedRow(inComponent: 1) * 5
        let minutesStr = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        
        return "\(hourStr)h\(minutesStr)"
    }
}

//MARK: - Delegate / Datasource -
extension MJTimePickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 24
        }
        //Minutes
        return 60 / 5
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if component == 1 {
//            pickerView.reloadComponent(0)
//        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return row < 10 ? "0\(row)" : "\(row)"
        }
        let newRow = row * 5
        return newRow < 10 ? "0\(newRow)" : "\(newRow)"
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let attrs = [NSAttributedString.Key.foregroundColor : UIColor.appOrange]
        
        if component == 0 {
            return  NSAttributedString(string: row < 10 ? "0\(row)" : "\(row)",attributes: attrs)
        }
        let newRow = row * 5
        return  NSAttributedString(string: newRow < 10 ? "0\(newRow)" : "\(newRow)",attributes: attrs)
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
//        if component == 0 {
//            return 60
//        }
        return 60
    }
}
