//
//  EventDatesCell.swift
//  entourage
//
//  Created by Jerome on 24/06/2022.
//

import UIKit

class EventDatesCell: UITableViewCell {
    
    @IBOutlet weak var ui_view_date_error: MJErrorInputTextView!
    @IBOutlet weak var ui_title_date: UILabel!
    @IBOutlet weak var ui_tf_date: UITextField!
    
    @IBOutlet weak var ui_view_time_start_error: MJErrorInputTextView!
    @IBOutlet weak var ui_title_time_start: UILabel!
    @IBOutlet weak var ui_tf_time_start: UITextField!
    
    @IBOutlet weak var ui_view_time_end_error: MJErrorInputTextView!
    @IBOutlet weak var ui_title_time_end: UILabel!
    @IBOutlet weak var ui_tf_time_end: UITextField!
    
    
    var pickerDateView = UIDatePicker()
    
    var pickerTimeStartView = UIDatePicker()
    var pickerTimeEndView = UIDatePicker()
    
    var selectedDate:Date? = nil
    var selectedTimeStart:Date? = nil
    var selectedTimeEnd:Date? = nil
    
    let currentLocale = Locale.init(identifier: "fr-FR")
    
    weak var delegate:EventCreateDateCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.ui_view_date_error?.setupView(title: "eventCreateInputErrorMandatory".localized)
        self.ui_view_time_start_error?.setupView(title: "eventCreateInputErrorTimeStart".localized)
        self.ui_view_time_end_error?.setupView(title: "eventCreateInputErrorTimeEnd".localized)
        
        let stringAttr = Utils.formatString(messageTxt: "event_create_phase2_date".localized, messageTxtHighlight: "event_create_mandatory".localized, fontColorType: ApplicationTheme.getFontH2Noir(size: 15), fontColorTypeHighlight: ApplicationTheme.getFontLegend(size: 13))
        ui_title_date.attributedText = stringAttr
        
        
        pickerDateView = UIDatePicker()
        pickerDateView.datePickerMode = .date
        pickerDateView.locale = currentLocale
        
        if #available(iOS 13.4, *) {
            pickerDateView.preferredDatePickerStyle = .wheels
        }
        setupPickerDayMonthView(textView: ui_tf_date, validateSelector: #selector(validateDate), cancelSelector: #selector(cancelDate),datePicker: pickerDateView)
        
        pickerTimeStartView = UIDatePicker()
        pickerTimeStartView.datePickerMode = .time
        if #available(iOS 13.4, *) {
            pickerTimeStartView.preferredDatePickerStyle = .wheels
        }
        
        setupPickerDayMonthView(textView: ui_tf_time_start, validateSelector: #selector(validateTimeStart), cancelSelector: #selector(cancelTimeStart), datePicker: pickerTimeStartView)
        ui_tf_time_start.delegate = self
        
        pickerTimeEndView = UIDatePicker()
        pickerTimeEndView.datePickerMode = .time
        if #available(iOS 13.4, *) {
            pickerTimeEndView.preferredDatePickerStyle = .wheels
        }
        
        setupPickerDayMonthView(textView: ui_tf_time_end, validateSelector: #selector(validateTimeEnd), cancelSelector: #selector(cancelTimeEnd), datePicker: pickerTimeEndView)
        ui_tf_time_end.delegate = self
        
        ui_view_date_error.isHidden = true
        ui_view_time_end_error.isHidden = true
        ui_view_time_start_error.isHidden = true
    }
    
    func populateCell(startDate:Date?, endDate:Date?,delegate:EventCreateDateCellDelegate?) {
        self.delegate = delegate
        self.selectedDate = startDate
        self.selectedTimeStart = startDate
        self.selectedTimeEnd = endDate
        
        let dateFormatter = getDateFormatter()
        let timeFormatter = getTimeFormatter()
        
        if let startDate = startDate {
            ui_tf_date.text = dateFormatter.string(from: startDate)
            ui_tf_time_start.text = timeFormatter.string(from: startDate)
        }
        if let endDate = endDate {
            ui_tf_time_end.text = timeFormatter.string(from: endDate)
        }
    }
    
    //MARK: Picker date -
    private func setupPickerDayMonthView(textView: UITextField, validateSelector:Selector, cancelSelector:Selector, datePicker:UIDatePicker? = nil){
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "validate".localized, style: .plain, target: self, action: validateSelector )//#selector(donedatePicker)
        doneButton.tintColor = .appOrange
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "cancel".localized, style: .plain, target: self, action: cancelSelector)
        cancelButton.tintColor = .appOrangeLight
        
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        toolbar.backgroundColor = .appWhite246
        
        textView.inputAccessoryView = toolbar
        textView.inputView = datePicker
    }
    
    @objc private func validateDate(){
        let formatter = getDateFormatter()
        ui_tf_date.text = formatter.string(from: pickerDateView.date)
        self.contentView.endEditing(true)
        selectedDate = pickerDateView.date
        
        delegate?.setDateChanged()
        selectedTimeStart = nil
        ui_tf_time_start.text = ""
        delegate?.addDateStart(dateStart: nil)
        
        selectedTimeEnd = nil
        ui_tf_time_end.text = ""
        delegate?.addDateEnd(dateEnd: nil)
    }
    
    @objc private func cancelDate(){
        self.contentView.endEditing(true)
    }
    
    @objc private func validateTimeStart(){
        self.validateTime(isStart: true)
    }
    
    @objc private func cancelTimeStart(){
        self.contentView.endEditing(true)
    }
    
    @objc private func validateTimeEnd(){
        self.validateTime(isStart: false)
    }
    
    @objc private func cancelTimeEnd(){
        self.contentView.endEditing(true)
    }
    
    private func validateTime(isStart:Bool) {
        let formatter = getTimeFormatter()
        if isStart {
            ui_view_time_start_error.isHidden = true
            selectedTimeStart = pickerTimeStartView.date
            ui_tf_time_start.text = formatter.string(from: pickerTimeStartView.date)
            delegate?.addDateStart(dateStart: pickerTimeStartView.date)
            
            selectedTimeEnd = nil
            ui_tf_time_end.text = ""
            delegate?.addDateEnd(dateEnd: nil)
        }
        else {
            ui_view_time_end_error.isHidden = true
            ui_tf_time_end.text = formatter.string(from: pickerTimeEndView.date)
            delegate?.addDateEnd(dateEnd: pickerTimeEndView.date)
        }
        self.contentView.endEditing(true)
    }
    
    private func getDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = currentLocale
        formatter.dateFormat = "dd/MM/YYYY"
        return formatter
    }
    private func getTimeFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH'h'mm"
        
        return formatter
    }
}

//MARK: - UITextFieldDelegate -
extension EventDatesCell:UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case ui_tf_date:
            if selectedDate != nil {
                pickerDateView.date = selectedDate!
            }
        case ui_tf_time_start:
            if selectedDate == nil {
                ui_view_time_start_error.isHidden = false
                return false
            }
            else {
                if let newDate = selectedDate?.setStartOfDay() {
                    pickerTimeStartView.date = newDate
                }
            }
        case ui_tf_time_end:
            if selectedTimeStart == nil {
                ui_view_time_end_error.isHidden = false
                return false
            }
            else {
                if let _newDate = selectedTimeStart {
                    let newDate = _newDate.addingTimeInterval(3 * 60 * 60)
                    pickerTimeEndView.minimumDate = _newDate
                    pickerTimeEndView.maximumDate = _newDate.setEndOfDay()
                    pickerTimeEndView.date = newDate
                }
            }
        default:
            break
        }
        return true
    }
}

//MARK: - Protocol EventCreateDateCellDelegate -
protocol EventCreateDateCellDelegate:AnyObject {
    func addDateStart(dateStart: Date?)
    func addDateEnd(dateEnd: Date?)
    func addRecurrence(recurrence: EventRecurrence)
    func setDateChanged()
}
