//
//  MJDayMonthPicker.swift
//  entourage
//
//  Created by Jerome on 06/04/2022.
//

import UIKit

class MJDayMonthPicker: UIPickerView {
    
    var months: Array<String> = [String]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config(localeStr: "fr-FR")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    func config(localeStr:String) {
        
        var calendar = Calendar.current
        calendar.locale = Locale.init(identifier: localeStr)
        
        months = calendar.monthSymbols
        
        delegate = self
        dataSource = self
        
        backgroundColor = .white
    }
    
    func getDateSelected() -> (day:String, month:String) {
        let day = selectedRow(inComponent: 0) + 1
        let dayStr = day < 10 ? "0\(day)" : "\(day)"
        
        let month = selectedRow(inComponent: 1) + 1
        let monthStr = month < 10 ? "0\(month)" : "\(month)"
        
        return (dayStr,monthStr)
    }
}

//MARK: - Delegate / Datasource -
extension MJDayMonthPicker: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRows = 0
        if component == 1 {
            //Number of months ;)
            numberOfRows = 12
        }
        else if pickerView.numberOfComponents > 1 {
            //Calculate number of days in function of the month
            let month: Int = pickerView.selectedRow(inComponent: 1) + 1
            var selectedMonth = DateComponents()
            selectedMonth.month = month
            selectedMonth.day = 1
            
            var nextMonth = DateComponents()
            nextMonth.month = month + 1
            nextMonth.day = 1
            
            let thisMonthDate = Calendar.current.date(from: selectedMonth)
            let nextMonthDate = Calendar.current.date(from: nextMonth)
            
            let difference = Calendar.current.dateComponents([.day], from: thisMonthDate!, to: nextMonthDate!)
            numberOfRows = difference.day!
            
            if month == 2 {
                numberOfRows = numberOfRows + 1 //To add february 29
            }
        }
        return numberOfRows
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 1 {
            pickerView.reloadComponent(0)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return  String(format: "%d", row+1)
        }
        else {
            return months[row].localizedCapitalized
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let attrs = [NSAttributedString.Key.foregroundColor : UIColor.appOrange]
        
        if component == 0 {
            return  NSAttributedString(string:String(format: "%d", row+1),attributes: attrs)
        }
        else {
            return NSAttributedString(string:months[row].localizedCapitalized, attributes: attrs)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 0 {
            return 60
        }
        return 150
    }
}
