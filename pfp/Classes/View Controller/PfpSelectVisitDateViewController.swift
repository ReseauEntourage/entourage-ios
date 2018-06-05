//
//  PfpSelectVisitDateViewController.swift
//  pfp
//
//  Created by Smart Care on 05/06/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import UIKit

class PfpSelectVisitDateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var datePicker:UIDatePicker!
    
    var selectedCellType: DateSelectionType = .today
    var selectedDate:Date?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.datePicker.datePickerMode = UIDatePickerMode.dateAndTime
        self.title = String.localized("pfp_date_title").uppercased()
        self.tableView.backgroundColor = UIColor.pfpTableBackground()
        
        self.selectDateType(.today, date: Date())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func selectDateType (_ type: DateSelectionType, date:Date?) {
        self.selectedCellType = type
        self.selectedDate = date
        self.tableView.reloadData()
        self.datePicker.isHidden = self.selectedCellType != .custom
    }
    
    //MARK:-  Table View Delegate & DataSource -
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "scsdc"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PfpSelectDateCell = tableView.dequeueReusableCell(withIdentifier: "PfpSelectDateCell", for: indexPath) as! PfpSelectDateCell
        let currentType:DateSelectionType = DateSelectionType(rawValue: indexPath.row)!
        let isSelected = self.selectedCellType == currentType
        cell.type = currentType
        cell.updateWithType(currentType, selected: isSelected, date: self.selectedDate)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentType:DateSelectionType = DateSelectionType(rawValue: indexPath.row)!
        var date:Date? = Date()

        switch currentType {
        case .yesterday:
            let today:Date = Date()
            date = Calendar.current.date(byAdding: Calendar.Component.day, value: -1, to: today)!
            break
        default:
            break
        }
        
        self.selectDateType(currentType, date: date)
    }
}
