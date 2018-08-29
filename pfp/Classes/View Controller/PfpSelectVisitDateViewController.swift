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
    var privateCircle:OTUserMembershipListItem?
    
    let tableHeaderSectionHeight: CGFloat = 40

    override func viewDidLoad() {
        super.viewDidLoad()

        self.datePicker.datePickerMode = UIDatePickerMode.date
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
        self.updateNavigationItems()
    }
    
    private func updateNavigationItems () {
        let continueButton:UIBarButtonItem = UIBarButtonItem.init(title: String.localized("continue"),
                                                                  style: UIBarButtonItemStyle.plain,
                                                                  target: self,
                                                                  action: #selector(continueAction))
        
        if self.selectedDate != nil {
            self.navigationItem.rightBarButtonItem = continueButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func selectDateType (_ type: DateSelectionType, date:Date?) {
        self.selectedCellType = type
        self.selectedDate = date
        self.tableView.reloadData()
        self.datePicker.isHidden = self.selectedCellType != .custom
        self.datePicker.date = Date()
    }
    
    @IBAction func selectColorAction(_ sender: UIDatePicker) {
        self.selectedDate = sender.date
        self.tableView.reloadData()
    }
    
    @objc private func continueAction () {
        SVProgressHUD.show()
        PfpApiService.sendLastVisit(self.selectedDate, privateCircle: self.privateCircle!) { (error: Error?) in

            if error == nil {
                SVProgressHUD.showSuccess(withStatus: String.localized("pfp_last_visit_sent"))
                self.navigationController?.popToRootViewController(animated: false)
                OTAppState.switchToMessagesScreen()
                
            } else {
                SVProgressHUD.showError(withStatus: String.localized("requestNotSent"))
            }
        }
    }
    
    //MARK:-  Table View Delegate & DataSource -
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableHeaderSectionHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.bounds.size.width, height: tableHeaderSectionHeight))
        header.backgroundColor = UIColor.clear
        
        let label:UILabel = UILabel.init(frame: CGRect.init(x: 15, y: 0, width: tableView.bounds.size.width, height: tableHeaderSectionHeight))
        label.text = String.localized("pfp_last_visit_title")
        label.font = UIFont.SFUIText(size: 15, type: .semibold)
        label.textColor = ApplicationTheme.shared().titleLabelColor
        header.addSubview(label)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PfpSelectDateCell = tableView.dequeueReusableCell(withIdentifier: "PfpSelectDateCell", for: indexPath) as! PfpSelectDateCell
        let currentType:DateSelectionType = DateSelectionType(rawValue: indexPath.row)!
        let isSelected = self.selectedCellType == currentType
        cell.type = currentType
        cell.updateWithType(currentType, isSelected: isSelected,
                            selectedType: self.selectedCellType, date: self.selectedDate)
        
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
