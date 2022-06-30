//
//  EventCreatePhase1ViewController.swift
//  entourage
//
//  Created by Jerome on 21/06/2022.
//

import UIKit

class EventCreatePhase2ViewController: UIViewController {
    
    weak var pageDelegate:EventCreateMainDelegate? = nil
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    var startDateSelected:Date? = nil
    var endDateSelected:Date? = nil
    var recurrenceSelected:EventRecurrence = .once
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        ui_tableview.rowHeight = UITableView.automaticDimension
        ui_tableview.estimatedRowHeight = 50
    }
}

//MARK: - UITableView datasource / Delegate -
extension EventCreatePhase2ViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDate", for: indexPath) as! EventDatesCell
            
            cell.populateCell(startDate:startDateSelected, endDate:endDateSelected, delegate: self)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSelector", for: indexPath) as! EventRecurrenceCell
        cell.populateCell(recurrence:recurrenceSelected, delegate: self)
        return cell
    }
}

//MARK: - EventCreateDateCellDelegate -
extension EventCreatePhase2ViewController: EventCreateDateCellDelegate {
    func addDateStart(dateStart: Date?) {
        startDateSelected = dateStart
        pageDelegate?.addDateStart(dateStart: dateStart)
    }
    
    func addDateEnd(dateEnd: Date?) {
        endDateSelected = dateEnd
        pageDelegate?.addDateEnd(dateEnd: dateEnd)
    }
    
    func addRecurrence(recurrence: EventRecurrence) {
        recurrenceSelected = recurrence
        pageDelegate?.addRecurrence(recurrence: recurrence)
    }
}
